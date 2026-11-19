# Regras para conversas neste repositório

Fale sempre em português.

## Antes

- `git pull`. Se houver mudança local que não é sua, pare e pergunte.
- Este repositório é **público**: nada de domínio, IP, e-mail ou segredo reais em código, docs ou exemplos. Use `example.com`.
- Sem Go instalado, o `./build.sh` compila e testa num container. Antes de dizer que está pronto: `go vet` e `go test` passando.


## Testes

- Os testes (`go test ./...`) usam um Nextcloud falso em memória: não precisam de servidor.
- Nunca teste contra a pasta do Claude Code em uso (`CLAUDE_CONFIG_DIR`) nem contra o Nextcloud de verdade: use pastas temporárias, apagadas no fim.
- O executável compilado vai para `dist/`, fora do git. Apague o que não for publicar.

## Commits

- Só com autorização de quem pediu a mudança.
- E-mail pessoal, nunca o do trabalho: confira `git config user.email` contra `git log -3 --format=%ae`.
- Nunca credenciais, `config.json` ou `state.json` de um PC real.
