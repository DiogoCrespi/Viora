# Viora - Aplicativo Flutter

## Visão Geral

Viora é um aplicativo móvel moderno desenvolvido com Flutter, oferecendo uma experiência completa de usuário com foco em jogos e interatividade. O projeto implementa uma arquitetura limpa (Clean Architecture) e utiliza tecnologias modernas para garantir uma experiência de usuário fluida e escalável.

## Funcionalidades Principais

### Autenticação e Usuário
* **Sistema de Autenticação Completo**
  * Login com email/senha
  * Cadastro de novos usuários
  * Recuperação de senha
  * Perfil de usuário personalizável
  * Configurações de preferências do usuário

### Jogos e Interatividade
* **Módulo de Jogos**
  * Sistema de jogos interativos
  * Progressão e conquistas
  * Sistema de pontuação
  * Integração com perfil do usuário

### Onboarding e UX
* **Processo de Onboarding**
  * Tutorial interativo para novos usuários
  * Introdução às funcionalidades principais
  * Configuração inicial de preferências

### Personalização
* **Tema e Acessibilidade**
  * Suporte a tema claro/escuro
  * Ajuste de tamanho de fonte
  * Interface adaptativa
  * Suporte a múltiplos idiomas (PT-BR e EN)

## Arquitetura e Tecnologias

### Frontend
* **Flutter**: Framework principal para desenvolvimento multiplataforma
* **Clean Architecture**: Separação clara de responsabilidades
  * Features (auth, user, game, onboarding)
  * Core (config, database, utils, constants)
  * Presentation (UI components, providers)

### Backend e Armazenamento
* **Supabase**
  * Autenticação de usuários
  * Banco de dados em tempo real
  * Armazenamento de arquivos
  * Funções serverless

* **SQLite Local**
  * Cache de dados
  * Armazenamento offline
  * Preferências do usuário

### Gerenciamento de Estado e Navegação
* **Providers**: Gerenciamento de estado da aplicação
* **GoRouter**: Sistema de navegação e rotas
* **Riverpod**: Injeção de dependências e gerenciamento de estado

## Estrutura do Projeto

```
lib/
├── core/                 # Funcionalidades core da aplicação
│   ├── config/          # Configurações (Supabase, etc)
│   ├── constants/       # Constantes e enums
│   ├── database/        # Configuração e helpers do banco de dados
│   ├── platform/        # Implementações específicas de plataforma
│   └── utils/           # Utilitários e helpers
│
├── features/            # Módulos principais da aplicação
│   ├── auth/           # Autenticação e autorização
│   ├── game/           # Lógica e modelos de jogos
│   ├── onboarding/     # Processo de onboarding
│   └── user/           # Gerenciamento de usuário
│
├── presentation/        # Componentes de UI e providers
│   ├── pages/          # Telas principais
│   ├── providers/      # Gerenciamento de estado
│   └── widgets/        # Componentes reutilizáveis
│
├── l10n/               # Arquivos de internacionalização
├── main.dart           # Ponto de entrada da aplicação
└── routes.dart         # Configuração de rotas
```

## Configuração do Ambiente

1. **Pré-requisitos**
   * Flutter SDK (versão mais recente)
   * Dart SDK
   * Android Studio / VS Code
   * Git

2. **Configuração Inicial**
   ```bash
   # Clone o repositório
   git clone https://github.com/DiogoCrespi/Viora.git
   
   # Entre no diretório
   cd Viora
   
   # Instale as dependências
   flutter pub get
   ```

3. **Configuração do Supabase**
   * Crie uma conta no Supabase
   * Configure as variáveis de ambiente em `lib/core/config/supabase_config.dart`
   * Execute as migrações do banco de dados

4. **Executando o Projeto**
   ```bash
   # Em modo debug
   flutter run
   
   # Para produção
   flutter run --release
   ```

## Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.
