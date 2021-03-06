%{
#include <stdio.h>
#include "tabela.h"
#include "arvore.h"

int yylex(void);
void yyerror(char *);

pilha_contexto *pilha;

%}

%token PRINT NUMBER ID END IF ELSE FOR FUNCTION EXPR ATTR ADD SUB
%left '+' '-'
%left '*' '/'
%%


program:
			
	program bloco		{ }
	|
	; 	

bloco: 
	initbloco			{ tabela *contexto = criar_contexto(topo_pilha(pilha));
				  pilha = empilhar_contexto(pilha, contexto);

				 }
	stmts fim	{ imprimir_contexto(topo_pilha(pilha));
				  desempilhar_contexto(&pilha); }
	;


fim:
    END
    |
    ;

initbloco:
    funcao
    |
    ;
funcao:
    FUNCTION ID '('expr')'
    ;


stmts: 
	stmts stmt
	| 	
	;

stmt:
	expr		{	}
	| bloco
	| attr			{	}

	;

attr: 
	ID '=' expr 		{ simbolo * s = localizar_simbolo(topo_pilha(pilha), (char *) $1);
                    if(s == NULL){
                        s = criar_simbolo((char *) $1, 1); 
					    inserir_simbolo(topo_pilha(pilha), s);
                    }
					no_arvore *n = criar_no_atribuicao(s, (void *) $3);
					$$ = (int) n;
				  
				}
expr:

	 NUMBER			{ no_arvore *n = criar_no_expressao(NUMBER, (void *) $1, NULL); 
				  $$ = (int) n; }
	| ID			{ simbolo * s = localizar_simbolo(topo_pilha(pilha), (char *) $1);
				  if(s == NULL)
					yyerror("Identificador não declarado");
				  else  {
					no_arvore *n = criar_no_expressao(ID, s, NULL);
					$$ = (int) n;
				  }
				}
	| expr'+' expr		{ no_arvore *n = criar_no_expressao('+', (void *) $1, (void *) $3); 
				         $$ = (int) n; }
	| expr '-' expr		{ no_arvore *n = criar_no_expressao('-', (void *) $1, (void *) $3);
                         $$ = (int) n; }
    | expr '*' expr		{ no_arvore *n = criar_no_expressao('*', (void *) $1, (void *) $3);
                         $$ = (int) n; }
    | expr '/' expr		{ no_arvore *n = criar_no_expressao('/', (void *) $1, (void *) $3);
                         $$ = (int) n; }

//passa a referencia para a tabela de símbolos contextual com 
//topo_pilha(pilha) 
				 
	| '(' expr ')'		{ $$ = $2; }
	; 

%%

void yyerror(char *s) {
	fprintf(stderr, "%s\n", s);
}

int main(void) {
	pilha = NULL;
	yyparse();
	return 0;
}
