# Trabalho Prático - Análise de Dados Públicos
## Introdução a Bancos de Dados (IBD) - UFMG

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18-blue)](https://www.postgresql.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Data: Public](https://img.shields.io/badge/Data-Public-green)](https://dados.gov.br)

## Sobre o Projeto

Este trabalho acadêmico tem como objetivo demonstrar o processo completo de acesso, coleta, gerenciamento, integração e análise de conjuntos de dados públicos.

O projeto integra dados de população municipal (IBGE) com dados de frota de veículos (SENATRAN) para todos os 5.571 municípios brasileiros, permitindo análises sobre padrões de motorização, desenvolvimento regional e mobilidade urbana.

###  Equipe

- Bruno Gontijo
- Pedro Pethes  
- Cauã Dutra

---

## Fontes de Dados

### 1. População Municipal 2024
- Fonte: Instituto Brasileiro de Geografia e Estatística (IBGE)
- URL: https://www.ibge.gov.br
- Data de Obtenção: Outubro/2025
- Cobertura: 5.571 municípios brasileiros
- Descrição: Estimativas populacionais para o ano de 2024

### 2. Frota de Veículos Municipal 2024
- Fonte: Secretaria Nacional de Trânsito (SENATRAN)
- URL: https://dados.gov.br
- Data de Obtenção: Outubro/2025  
- Cobertura: 5.571 municípios brasileiros
- Descrição: Frota de veículos registrados por município e categoria

---

## Estrutura do Repositório

```
tp_ibd/
├── README.md                    # Este arquivo
├── .gitignore                   # Arquivos a serem ignorados pelo Git
│
├── data/                        # Dados originais e processados
│   ├── frota_municipio_2024.csv
│   └── pop_municipio_2024_limpo.csv
│
├── sql/                         # Scripts SQL
|   ├── ScriptsSQL
│
└── docs/                        # Documentação
    ├── Relatorio_Parte1.pdf
    ├── Relatorio_Parte2.pdf
    ├── Dicionario_Dados.pdf
    └── Esquema_ER.png
```


## Como Reproduzir as Análises

### Pré-requisitos

- PostgreSQL 18+ instalado
- pgAdmin 4 (opcional, para interface gráfica)
- Git (para clonar o repositório)

### Passo 1: Clonar o Repositório

```bash
git clone https://github.com/seu-usuario/tp_ibd.git
cd tp_ibd
```

### Passo 2: Criar o Banco de Dados

```bash
# No terminal PostgreSQL (psql)
createdb ibd_trabalho

# Ou pelo pgAdmin: botão direito em Databases → Create → Database
```

### Passo 3: Executar os Scripts SQL

Execute os scripts na ordem:

```bash
psql -d ibd_trabalho -f sql/01_criar_tabelas.sql
psql -d ibd_trabalho -f sql/02_importar_dados.sql
psql -d ibd_trabalho -f sql/03_integrar_dados.sql
psql -d ibd_trabalho -f sql/04_analises_exploratorias.sql
```

Ou pelo pgAdmin:
1. Abra cada arquivo `.sql`
2. Execute com F5 ou botão "Execute"

### Passo 4: Ajustar Caminhos dos Arquivos CSV

No arquivo `02_importar_dados.sql`, ajuste os caminhos para onde seus arquivos CSV estão localizados:

```sql
-- Altere estas linhas conforme seu sistema:
COPY frota FROM '/seu/caminho/data/frota_municipio_2024.csv' ...
COPY municipio_temp FROM '/seu/caminho/data/pop_municipio_2024_limpo.csv' ...
```

---

## Principais Resultados

### Estatísticas Gerais

- População Total Brasil: 212.583.750 habitantes
- Frota Total Brasil: 121.836.610 veículos
- Taxa Média Nacional: 0,57 veículos por habitante

## Esquema do Banco de Dados

### Tabelas Principais

#### `municipio`
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| ibge_id | INTEGER (PK) | Código IBGE (7 dígitos) |
| nome | TEXT | Nome do município |
| uf | VARCHAR(2) | Sigla da UF |
| populacao_2024 | INTEGER | População estimada 2024 |

#### `frota`
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| uf | VARCHAR(2) | Sigla da UF |
| municipio | VARCHAR(80) | Nome do município |
| ibge_id | INTEGER (FK) | Código IBGE |
| total | INTEGER | Total de veículos |
| automovel | INTEGER | Quantidade de automóveis |
| motocicleta | INTEGER | Quantidade de motocicletas |
| caminhao | INTEGER | Quantidade de caminhões |
| onibus | INTEGER | Quantidade de ônibus |
| ... | ... | Outras 15+ categorias |

Chave de Integração: `ibge_id` (relacionamento 1:1)

Ver diagrama completo em: `docs/Esquema_ER.png`

---

## Análises Disponíveis

Os scripts em `sql/04_analises_exploratorias.sql` incluem:

- ✅ Estatísticas descritivas (média, mediana, min, max)
- ✅ Ranking de municípios (população e frota)
- ✅ Distribuição por tipo de veículo
- ✅ Agregações por UF e região
- ✅ Cálculo de veículos per capita
- ✅ Identificação de outliers
- ✅ Análise de correlações
- ✅ Padrões por faixa populacional

---

## Documentação Completa

Consulte a pasta `/docs/` para:

- Relatório Parte 1: Processo de coleta e integração dos dados
- Relatório Parte 2: Análise exploratória completa e insights
- Dicionário de Dados: Descrição detalhada de todas as colunas
- Esquema ER: Modelo conceitual do banco de dados

---

## Limitações Conhecidas

1. Divergências de Nomenclatura: 44 municípios (0,79%) requereram normalização manual para integração
2. Dados Estimados: População baseada em estimativas do IBGE (não é censo)
3. Outliers: Alguns municípios apresentam valores atípicos (turísticos, ribeirinhos, etc.)
4. Registro vs Circulação: Frota registrada ≠ frota efetivamente circulante
5. Sazonalidade: Municípios turísticos têm frota flutuante não capturada

Ver análise crítica completa no `Relatorio_Parte2.pdf`.

---

## Licença

Os dados utilizados são públicos e provêm de fontes oficiais (IBGE e SENATRAN).


