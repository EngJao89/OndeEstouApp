# OndeEstouApp

## Descrição do projeto

**OndeEstouApp** é um aplicativo iOS que permite ao usuário registrar e visualizar locais de viagem no mapa. O app usa a localização atual do dispositivo e permite marcar novos pontos com um gesto de toque longo no mapa; cada ponto é salvo com endereço (via reverse geocoding) e coordenadas, e pode ser listado, visualizado e removido.

### Funcionalidades principais

- **Ver localização atual** no mapa ao adicionar um novo local.
- **Marcar locais no mapa**: toque longo (2 segundos) em um ponto para salvar o local com endereço e coordenadas.
- **Lista de locais**: tela com todos os locais salvos; ao tocar em um item, o mapa abre centralizado nesse ponto.
- **Exclusão**: deslize na célula da lista para remover um local salvo.
- **Permissão de localização**: uso de localização “enquanto estiver usando o app”; em caso de negação, o app orienta a abrir as configurações.

---

## Como rodar o projeto

### Pré-requisitos

- **macOS** (necessário para compilar e rodar apps iOS).
- **Xcode 16.1** ou superior (compatível com o projeto).
- **Dispositivo iOS 18.1+** ou simulador com iOS 18.1+.
- **Conta Apple** (gratuita) para assinar o app no simulador ou dispositivo.

### Passos

1. **Clonar o repositório** (se ainda não tiver):
   ```bash
   git clone <url-do-repositorio>
   cd OndeEstouApp
   ```

2. **Abrir no Xcode**
   - Abra o arquivo `OndeEstouApp.xcodeproj` no Xcode (duplo clique ou `open OndeEstouApp.xcodeproj` no Terminal).

3. **Selecionar o destino**
   - No topo do Xcode, escolha um **simulador** (ex.: iPhone 16) ou um **dispositivo físico** conectado.

4. **Compilar e executar**
   - Pressione **⌘ + R** ou use o botão **Run** (▶).
   - No simulador, a localização pode ser simulada em **Features → Location** (ex.: “Custom Location” ou “City Run”).

5. **Permissão de localização**
   - Na primeira vez que o app pedir localização, aceite “Permitir ao usar o app” para ver sua posição no mapa e marcar novos locais.

---

## Decisões técnicas e arquiteturais

### Stack e ferramentas

- **Linguagem**: Swift 5.0  
- **UI**: UIKit com **Storyboards** (Main.storyboard) e **Interface Builder**  
- **Mapas e localização**: **MapKit** (MKMapView, MKPointAnnotation) e **Core Location** (CLLocationManager, CLGeocoder)  
- **Persistência**: **UserDefaults** para armazenar a lista de viagens no dispositivo  
- **Ciclo de vida**: **AppDelegate** + **SceneDelegate** (padrão iOS 13+)  
- **Deployment**: iOS 18.1+, apenas **iPhone** (LSRequiresIPhoneOS)

### Arquitetura

- **MVC**: cada tela é um ViewController (ViewController para o mapa, LocaisViagemViewController para a lista); modelo implícito nos dicionários de viagem e na classe `ArmazenamentoDados`.
- **Navegação**: segues no Storyboard (`verLocal`) para ir da lista ao mapa, passando dados via `prepare(for:sender:)` (viagem selecionada ou modo “adicionar” com `indiceSelecionado == -1`).
- **Dados**: viagens representadas como `[String: String]` com chaves `"local"`, `"latitude"` e `"longitude"`; persistidas em array no UserDefaults sob a chave `locaisViagem`.

### Decisões de design

1. **UserDefaults para persistência**  
   Escolha simples e suficiente para uma lista de locais no dispositivo, sem backend. Para muitos registros ou dados mais complexos, Core Data ou SwiftData seriam alternativas.

2. **Reverse geocoding no toque longo**  
   O endereço é obtido no momento em que o usuário marca o ponto (CLGeocoder), evitando dependência de serviços externos e mantendo o fluxo offline após o primeiro carregamento do mapa.

3. **Localização “when in use”**  
   Uso de `requestWhenInUseAuthorization()` e `NSLocationWhenInUseUsageDescription` no Info.plist, alinhado à política de privacidade da Apple e ao uso real do app (mapa visível).

4. **Gesto de toque longo (2 s)**  
   Reduz marcações acidentais; o usuário escolhe o ponto com mais precisão antes de disparar o geocoding e o salvamento.

5. **Storyboards e segues**  
   Projeto pequeno e fluxo linear (lista ↔ mapa), então Storyboards e segues mantêm o código de navegação concentrado e fácil de seguir.

6. **Sem dependências externas**  
   Apenas frameworks nativos (UIKit, MapKit, Core Location), o que simplifica manutenção e evita conflitos de versão.

### Estrutura do projeto

```
OndeEstouApp/
├── OndeEstouApp.xcodeproj/
├── OndeEstouApp/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── ViewController.swift          # Mapa, localização e marcação de locais
│   ├── LocaisViagemViewController.swift  # Lista e exclusão de viagens
│   ├── ArmazenamentoDados.swift      # Persistência em UserDefaults
│   ├── Info.plist
│   ├── Assets.xcassets/
│   └── Base.lproj/
└── README.md
```

---

## Requisitos do dispositivo

- iOS 18.1 ou superior  
- Serviços de localização e GPS (declarados em `UIRequiredDeviceCapabilities` no Info.plist)

---

## Licença e autoria

Projeto criado por João Ricardo Martins Ribeiro (novembro de 2024).
