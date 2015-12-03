# Lolzin
Site em Haskell.

Resumo dos links

Main - Página principal entitulada "Lolzin"
- Enquando o visitante não realizar Login ele só terá acesso as páginas "Roles List", "Champions List", "Login" e "Register"
- Após logado como usuário comum, ele pode dar Logout, acessar a Players List
- Se logado como admin, ele pode fazer tudo como um usuário comum, e acessar a página "Add Role"

Roles List - Página que mostram as roles básicas, sem adicão das feitas pelo admin
- Pode ser acessada por qualquer visitante/usuário/admin

Champions List - Página com exemplos de Champions para cadastro
- Pode ser acessada por qualquer pessoa

Login - Página de Login
- Pede ao visitante logar com seu Name e Champion cadastrado, a role é irrelevante na hora do Login e Registro
- Após logado, veja 2ª e 3ª linha de descrição do Main

Register - Página de registro
- Pede ao visitante para se registrar com Name, Champion e Role, embora a role seja apenas estético.
- Após o registro, o visitante ainda precisa se logar na página Login

Add Role - Página permitida apenas ao admin
- Nela, o admin pode adicionar roles exibidas no cadastro

Players List - Página que exibe todos os usuários comuns cadastrados (não exibe admins)
- Clicando em qualquer player, pode se ver suas informações de cadastro
- Caso o player clicado seja o da própria conta logada, há opção de Deletar este cadastro (consequentemente sendo deslogado)
- Caso o admin clique em qualquer player, ele pode deletá-lo do cadastro

Todas as páginas tem link de volta para a página anterior ou Main
