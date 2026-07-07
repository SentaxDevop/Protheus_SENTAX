# REPOSITÓRIO FONTES ERP PROTHEUS - HARPIA CONSULTORIA

## SENTAX
Este projeto visa o controle de fontes do ERP Protheus 

## Features

- Pontos de entrada
- Relatórios
- Rotinas diversas
- Rdmake padrão
- WorkFlow
- CNAB
## 🚀 Começando

Essas instruções permitirão que você obtenha uma cópia do projeto em operação na sua máquina local para fins de desenvolvimento e teste.

* Após o término do atendimento, adicione as alterações, fazer o commit(no formato: git commit -m "Descrição: Atividades diversas"), push e solicite o Code Review do seu trabalho(Pull Request). 
* Em pausas de projeto, não esqueça de salvar seus fontes que não foram validados na pasta ERP-CLIENTE\NOME_DO_CLIENTE\FONTES\. Nesta local, crie uma pasta com PROJETO + DATA + SEU_NOME (Exemplo: WMS_20230528_Luis)
* Siga as orientações da MDT01 e MDT09 para mantermos o padrão do atendimento entre os clientes.
* Nunca esqueça do cabeçalho nos fontes, devendo conter os seguintes:
 Dados do autor;
 Data;
 Objetivo do seu código;
 Histórico de alterações, data e quem solicitou;
 Comente funções e classes auxiliares.
* Comente o necessário.
* Indente seu código.
* Não criar branchs locais ou usar qualquer comando que deturpe a linha de commits/tempo.
* Enviar feedback com o máximo de 16hs após o término da agenda.
* Qualquer problema, acione imediatamente a coordenação ou seu GP.

### 📋 Pré-requisitos

Realize a instalação abaixo:?

```
Instale o VSCode mais atual na versão x64 bits.
```

```
Faça a instalação do plugin Totvs Developer.
```

```
Selecione a pasta aonde você vai alocar os fontes.
```

```
Faça a instalação do Git e configuração do GitHub conforme MDT01 de configuração, ou seguindo o próximo passo.
```

### 🔧 Instalação

Uma série de exemplos passo-a-passo que informam o que você deve executar para ter um ambiente de desenvolvimento em execução.

Diga como essa etapa será:

```
a)	Crie uma conta no GitHub;
```

```
b)	Solicite ao responsável pela infraestrutura dos fontes (Diogo), o vínculo da sua conta com a conta da Harpia;
```

```
c)	Faça a instalação da versão mais recente do Git (https://git-scm.com/download/win);
```
```
d)	Configure seu e-mail com o comando: git config --global user.email "seunome@harpiaconsultoria.com"
```
```
e)	Configure seu nome com o comando abaixo: git config --global user.name "seu.nome"
```
```
f)	Sinalize para o Git que você vai utilizar a pasta local como repositório: git init
```
```
g)	Vamos sincronizar o Git local com o GitHub, para isso, você precisará criar a chave SSH por ele, assim você insere a mesma na sua conta do GitHub. Isso autoriza seu computador a enviar arquivos para seu repositório GITHUB online.
```
```
h) Pronto, você já tem a conexão e você pode fazer o clone do repositório: git clone git@github.com:HarpiaERP/Rep_Cliente.git
```
## ⚙️ Executando os testes

*** Sempre procure utilizar a base de homologação/testes para desenvolvimento***

### 🔩 Testes Funcionais

Execute os testes funcionais e certifique-se da qualidade do desenvolvimento antes de liberar para validação final do cliente.

### ⌨️ Estilo de codificação

Utilize os recursos mais atuais da linguagem, como:
* MVC;
* Programação Orientada a Objetos;
* TLPP(TL++);
* RestFull;
* PO-UI.

## 📦 Implantação

Procure evitar ao máximo qualquer desconforto no momento de implantar seu projeto em produção, prefira realizar esta operação com calma, fora do expediente do cliente e seguindo as boas práticas de backup da aplicação e banco.

## 🛠️ Construído com

* [VsCode](https://code.visualstudio.com/download/) - Visual Studio Code
* [Plugin TOTVS](https://marketplace.visualstudio.com/items?itemName=totvs.tds-vscode) - TOTVS Develop Studio
* [Git](https://git-scm.com/download/win) - Git
* [GitHub](https://github.com/) - GitHub

## 🖇️ Colaborando

Por favor, qualquer dúvida sobre as práticas orientadas na integração, entre em contato com a coordenação ou o suporte de infraestrutura Harpia.
