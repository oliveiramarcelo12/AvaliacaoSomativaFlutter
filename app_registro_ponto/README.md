# Relatório de Implementação

## Descrição Técnica das Funcionalidades Implementadas e Decisões de Design

### Registro de Ponto com Geolocalização e Biometria
**Funcionalidade**:  
Permite que o usuário registre o ponto somente se estiver a até 100 metros do local designado.

**Design**:  
Decidimos implementar essa funcionalidade com Geolocator, que oferece precisão para verificar se o usuário está dentro do raio permitido. O botão de check-in é habilitado ou desabilitado conforme a localização, prevenindo registros fora do limite.

**Desafio**:  
Manter a precisão de localização em diferentes dispositivos sem consumir demasiada bateria. Foi configurada uma verificação de localização com precisão média e o uso otimizado para intervalos específicos de checagem.

---

### Autenticação com Firebase e Vinculação de Biometria
**Funcionalidade**:  
O usuário faz login com email e senha e, opcionalmente, vincula sua biometria (FaceID ou impressão digital) para logins futuros. Após a primeira autenticação, o usuário pode acessar o aplicativo apenas com biometria.

**Design**:  
Utilizamos Firebase Authentication para gerenciar o login inicial e armazenamos o consentimento do usuário para uso de biometria com SharedPreferences, garantindo que o vínculo biométrico seja persistente.

**Desafio**:  
Implementar a lógica de verificação para que a opção de biometria só seja oferecida após o primeiro login com email e senha, e garantir a segurança da autenticação biométrica com as configurações do dispositivo.

---

### Registro de Entrada e Saída com Verificação Facial
**Funcionalidade**:  
Captura uma foto do usuário no momento do registro de ponto, com uma verificação facial feita por uma API externa, validando a imagem antes de concluir o check-in ou check-out.

**Design**:  
Para a verificação facial, integramos uma API de detecção facial da Azure Cognitive Services. Após o usuário tirar uma foto, ela é enviada para a API, que retorna se há um rosto detectado.

**Desafio**:  
Atrasos e falhas ocasionais no envio e processamento da foto na API. A solução incluiu melhorias no tratamento de erros e notificações ao usuário para tentar novamente em caso de falhas.

---

### Exibição de Histórico e Relatório de Ponto
**Funcionalidade**:  
O usuário pode visualizar o histórico de registros e um relatório mensal das horas trabalhadas.

**Design**:  
Dados armazenados no Firebase Firestore são exibidos em telas separadas, organizados por data. O relatório mensal inclui um cálculo total das horas registradas.

**Desafio**:  
A organização dos dados para exibir um resumo e a formatação de tempo total de trabalho foram otimizadas para melhor legibilidade.

---

## Especificação do Uso de APIs Externas e Integração com Firebase

### Firebase:
- **Auth**: Gerencia autenticação com email/senha e UID para identificar o usuário.
- **Firestore**: Armazena dados dos registros de ponto, incluindo horário e localização.
- **Storage**: Armazena as fotos capturadas durante o registro de ponto.

### Geolocator:
**Objetivo**:  
Obtém a localização atual do usuário para confirmar que ele está dentro do raio permitido para o registro de ponto.

### Azure Cognitive Services - API de Detecção Facial:
**Objetivo**:  
Detecta se a imagem capturada contém um rosto, ajudando a autenticar a identidade do usuário no momento do check-in ou check-out.

**Configuração**:  
A API recebe a URL da imagem no Firebase Storage, processa e responde com um JSON informando se um rosto foi detectado ou não.
