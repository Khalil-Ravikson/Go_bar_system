# GoBar System - Contexto do Projeto

## Visão Geral
Projeto: GoBar System (Ecosistema de Automação de Bar)
Stack: Flutter + Clean Architecture + DDD + SOLID
Database: SQLite/Drift (Offline-First)
Estado: Riverpod
Arquitetura: Offline-First com Outbox Pattern para sincronização

## Design System
- Tokens globais de design (cores, tipografia, espaçamentos)
- Verde neon característico como cor primária
- Layout responsivo: desktop (tablets) e mobile (smartphones)
- Componentes minimalistas premium para legibilidade em luz de bar

## Módulos Principais
1. **PDV Híbrido** - Gestão de comandas por mesa com estado isolado (Riverpod)
2. **Persistência Offline-First** - Drift/SQLite + Outbox Pattern
3. **Fechamento Ágil** - AppPaymentModal com PIX/Dinheiro/Cartão
4. **Sincronização** - WebSocket + monitoramento de conectividade

## Repositórios Flutter para Components e UI

### Gratuitos (GitHub)
- **Flutter-UI-Kit** (iampawan): templates reais de e-commerce, login, dashboards, animações
  → Use para: telas de PDV, login, listas de produtos
- **flutter-ui-kits** (Olayemi Garuba): UI Kits gratuitos do UpLabs
  → Use para: componentes prontos de UI
- **tdesign-flutter** (Tencent): componentes com tema customizável via JSON
  → Use para: temas e componentes consistently estilizados
- **appsrox/flutter-ui-screens**: telas UI focadas (não apps completos)
  → Use para: telas específicas (pagamento, catálogo, comandas)

### Pacotes pub.dev
- **Material Components** (incluso): Design oficial Google Material 3
- **Cupertino Widgets** (incluso): estilo iOS nativo
- **Flutter Neumorphic**: designs modernos com profundidade
- **Forui**: estilo shadcn, animações elegantes
- **fluent_ui**: design language Microsoft

### Sites de Templates
- **Flutter Library** (flutterlibrary.com): templates, UI kits, widgets com código de página única
- **GetWidget** (getwidget.dev): 100+ componentes open-source
- **FlutterFlow**: visual builder com exportação de componentes

## Regras de Código
1. **Clean Architecture**: manter separação clara entre Domain, Data, Presentation
2. **DDD**: entidades, value objects, repositories no domain layer
3. **SOLID**: princípios de design orientado a objetos
4. **Riverpod**: gerenciamento de estado reativo, um provider por responsabilidade
5. **Drift**: todas as queries tipadas, migrations versionadas
6. **Design Tokens**: nunca hardcode cores/espaçamentos, usar tokens do Design System
7. **Offline-First**: toda operação vai para outbox antes de sincronizar
8. **Testabilidade**: cada módulo deve ter unit tests + widget tests

## Preferências de Components
- Priorizar componentes reutilizáveis e customizáveis
- Usar Composition over Inheritance
- Criar wrappers sobre Material Components para consistência visual
- Feedback visual imediato em todas as interações
- Acessibilidade: semantic labels, tap targets ≥ 48dp

## Fluxo de Trabalho com Agente
1. Sempre gerar plano de tarefas antes de codificar
2. Produzir artefatos: task list, implementation plan, test results
3. Usar `/explore` para validar ideias antes de implementar
4. Usar `/new` para criar planos iniciais
5. Usar `/continue` para gerar proposta/spec/tasks gradualmente
6. Usar `/verify` para revisar código e garantir completude
7. Usar `/apply` para executar processo automaticamente