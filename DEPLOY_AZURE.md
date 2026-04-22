# Deploy Azure do PDV

Este projeto deve ser publicado como um ambiente novo, separado do `PEC83`.

## 1. O que muda com Publish Profile

Com `Publish Profile`, o GitHub Actions faz apenas o deploy do pacote.

Configuracoes da Azure como:

- criacao do `Web App`
- `Startup Command`
- variaveis de ambiente do Laravel
- configuracoes do PHP/Linux App Service

devem ser feitas manualmente no portal da Azure no novo ambiente.

O App Service PHP/Linux do Azure usa Nginx e, para Laravel, o arquivo importante no repositiorio e `default` na raiz do projeto. Ele precisa subir junto com o deploy.

## 2. Criar recursos novos

- Novo repositorio GitHub
- Novo `App Service` Linux com `PHP 8.2`
- Novo banco de dados, se voce quiser isolamento total do original

Se o novo projeto apontar para o mesmo banco do `PEC83`, os dois sistemas continuam compartilhando dados e migracoes.

## 3. Secret do repositorio GitHub

Em `GitHub -> Settings -> Secrets and variables -> Actions -> Secrets`, criar:

- `AZURE_WEBAPP_PUBLISH_PROFILE`

Esse secret deve receber o conteudo inteiro do arquivo de Publish Profile baixado do novo Web App.

O workflow atual deste projeto ja usa o nome fixo do Web App `pdv`, entao nao precisa criar `AZURE_WEBAPP_NAME` como variable para este repositorio.

## 4. Passos na Azure

No novo `App Service` Linux:

1. Em `Configuration -> Application settings`, adicionar:

- `APP_ENV=production`
- `APP_NAME=PDV`
- `APP_DEBUG=false`
- `APP_URL=https://SEU-APP.azurewebsites.net`
- `APP_KEY=base64:...`
- `APP_TIMEZONE=America/Sao_Paulo`
- `DB_TIMEZONE=-03:00`
- `APP_LOCALE=pt_BR`
- `APP_FALLBACK_LOCALE=en`
- `APP_FAKER_LOCALE=en_US`
- `APP_MAINTENANCE_DRIVER=file`
- `APP_STORAGE=/home/site/storage`
- `DB_CONNECTION=mysql`
- `DB_HOST=...`
- `DB_PORT=3306`
- `DB_DATABASE=...`
- `DB_USERNAME=...`
- `DB_PASSWORD=...`
- `LOG_CHANNEL=stack`
- `LOG_STACK=single`
- `LOG_LEVEL=debug`
- `SESSION_DRIVER=file`
- `CACHE_STORE=file`
- `QUEUE_CONNECTION=sync`
- `BROADCAST_CONNECTION=log`
- `FILESYSTEM_DISK=local`
- `SESSION_LIFETIME=120`
- `SESSION_ENCRYPT=false`
- `SESSION_PATH=/`
- `SESSION_DOMAIN=`
- `SESSION_SECURE_COOKIE=true`
- `WEBSITES_PORT=8080`
- `WEBSITE_RUN_FROM_PACKAGE=0`
- `WEBSITES_ENABLE_APP_SERVICE_STORAGE=true`
- `SCM_DO_BUILD_DURING_DEPLOYMENT=false`
- `WEBSITE_WEBDEPLOY_USE_SCM=true`

Se voce ainda nao for configurar SMTP agora, adicione tambem:

- `MAIL_MAILER=log`
- `MAIL_FROM_ADDRESS=cleriodias@gmail.com`
- `MAIL_FROM_NAME=PDV`

2. Em `Configuration -> General settings`, confirmar que o runtime e:

- `PHP 8.2`
- `Linux`

3. Em `Configuration -> General settings -> Startup Command`, definir:

```bash
cp /home/site/wwwroot/default /etc/nginx/sites-available/default && service nginx reload
```

4. Salvar as configuracoes e reiniciar o App Service.

5. Em `Overview`, baixar o `Publish Profile`.

## 5. Fluxo de publicacao

1. Inicializar o Git local.
2. Conectar ao novo repositorio remoto.
3. Subir a branch `main`.
4. Executar o workflow `Deploy to Azure Web App`.

## 6. Comandos locais

```powershell
git init -b main
git remote add origin https://github.com/SEU_USUARIO/SEU_REPOSITORIO.git
git add .
git commit -m "Estrutura inicial do PDV para deploy Azure"
git push -u origin main
```

## 7. Observacoes

- O workflow usa `/.github/workflows/deploy.yml`.
- O Azure precisa do arquivo `default` versionado na raiz do projeto para servir o Laravel a partir de `/public`.
- Se voce preferir manter o `Startup Command` apontando para `start.sh`, este repositorio tambem aplica a mesma troca por script.
- Arquivos sensiveis locais como `.env`, `.sql`, `.pfx` e `bkp/` nao devem ir para o Git.
- Se o deploy falhar no download do Publish Profile em app Linux, confirme primeiro `WEBSITE_WEBDEPLOY_USE_SCM=true`, salve, reinicie o app e baixe o perfil novamente.
