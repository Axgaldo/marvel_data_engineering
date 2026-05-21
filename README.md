# Marvel Data Engineering - dbt + Snowflake

Proyecto de transformación de datos del universo Marvel usando **dbt** y **Snowflake** con Incremental Fact Tables y SCD2 Snapshots.

---

## 🎯 Visión General

- **3 Fact Tables:** apariciones, créditos artísticos, capabilities
- **4 Snapshots SCD2:** rastrean cambios de characters, issues, affiliations, relationships
- **Incremental Processing:** optimiza ingestas nuevas
- **Métricas complejas:** revenue, ratings ponderados, complejidad narrativa
- **Data Tests:** uniqueness, relationships, accepted values

---

## 🏗️ Arquitectura

```
BRONZE (raw_characters, raw_comics) 
    ↓ (ingested_at)
SILVER (stg_* vistas)
    ↓ (loaded_at = ingested_at)
SNAPSHOTS (snp_characters, snp_issues, snp_affiliations, snp_relationships)
    ↓ (dbt_valid_from/to)
GOLD-CORE (dim_characters, dim_issues, dim_capabilities, dim_artists, dim_date, dim_series, dim_teams, dim_relationships)
    ↓
GOLD-MARTS (fct_issue_character_appearances, fct_issue_artist_credits, fct_character_capability_network)
```

---

## 📁 Estructura

```
models/marvel/
├── 1_staging/          # Vistas normalizadas de bronze
│   ├── characters/
│   ├── issues/
│   ├── artists/
│   └── _stg__models.yml
└── 2_marts/            # Tablas finales (Gold)
    ├── core/           # Dimensiones
    ├── facts/          # Fact tables incrementales
    └── _marts__models.yml

snapshots/marts/core/
├── snp_characters.sql
├── snp_issues.sql
├── snp_character_affiliations.sql
└── snp_character_relationships.sql
```

---

## 💾 Capas

| Capa | Ubicación | Tipo | Propósito |
|------|-----------|------|----------|
| **BRONZE** | Raw DB | JSON | Datos originales |
| **SILVER** | Silver DB | Vistas | Normalización |
| **SNAPSHOTS** | Gold DB | Tablas SCD2 | Histórico de cambios |
| **GOLD-CORE** | Gold DB | Tablas | Dimensiones limpias |
| **GOLD-MARTS** | Gold DB | Tablas Incremental | Fact tables para análisis |

---

## 📊 Fact Tables

### `fct_issue_character_appearances`
- **Grano:** issue + character
- **Key:** `[issue_id, character_id]`
- **Registros:** ~500K
- **Métricas:** rating, owns, revenue, quality/page

### `fct_issue_artist_credits`
- **Grano:** issue + artist + role
- **Key:** `[issue_id, artist_id, role_name]`
- **Registros:** ~200K
- **Métricas:** rating, owns, revenue, quality/page

### `fct_character_capability_network`
- **Grano:** character + capability
- **Key:** `[character_id, capability_name]`
- **Registros:** ~100K
- **Métricas:** rarity, characters_with_capability

---

## 🚀 Ejecución

```bash
# Build completo
dbt build --full-refresh

# Incremental
dbt build

# Solo staging
dbt run --select tag:staging

# Solo marts
dbt run --select tag:marts

# Snapshots
dbt snapshot

# Tests
dbt test

# Docs
dbt docs generate && dbt docs serve
```

---

## 🧪 Tests Automáticos

- **Uniqueness:** combinaciones de columnas en fact tables
- **Relationships:** FKs en dimensiones y facts
- **Accepted Values:** appearance_type, capability_rarity, living_status
- **Expression Tests:** validaciones lógicas

---

## ⚙️ Configuración

**Variables de Entorno:**
```
DBT_ENVIRONMENTS=DEV  # DEV, STAGING, PROD
```

**Databases:**
- `{ENV}_MARVEL_BRONZE_DB` - Raw
- `{ENV}_MARVEL_SILVER_DB.STAGING` - Staging
- `{ENV}_MARVEL_GOLD_DB.SNAPSHOT` - Snapshots
- `{ENV}_MARVEL_GOLD_DB.CORE` - Dimensiones
- `{ENV}_MARVEL_GOLD_DB.MARTS` - Facts

---

## 📈 Métricas Clave

| Métrica | Fórmula | Ubicación |
|---------|---------|-----------|
| `rating_weighted` | `rating * sqrt(ratings_count / MAX)` | dim_issues |
| `estimated_revenue` | `price * num_user_owns` | facts |
| `quality_per_page_ratio` | `rating / num_pages` | facts, dim_issues |
| `story_complexity_index` | `chars * universes` | dim_issues |
| `capability_rarity` | basada en popularidad | fct_capability_network |

---

## 📊 Datos

- **~20K personajes** con histórico SCD2
- **~50K issues** con métricas de complejidad
- **~5K artistas** con roles creativos
- **~500 capacidades** (superpoderes + habilidades)
- **~35K fechas** (1939-2036) con eras Marvel
- **~2K series** editoriales

---

## 👤 Autor

**Axgaldo** - Data Engineer

**Última actualización:** 2026-05-21 | **Rama:** dev_marvel_1
