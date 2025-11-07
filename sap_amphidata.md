# Pla d’Anàlisi Estadística (SAP)
Miquel Vàzquez-Santiago
2025-10-01

- [1. Introducció al Projecte](#1-introducció-al-projecte)
  - [1.1. Objectius Específics](#11-objectius-específics)
- [2. Dades](#2-dades)
  - [2.1. Fonts de Dades](#21-fonts-de-dades)
  - [2.2. Resum de Variables d’Estudi](#22-resum-de-variables-destudi)
  - [2.3. Diccionari de Variables](#23-diccionari-de-variables)
- [3. Preparació de les Dades](#3-preparació-de-les-dades)
  - [3.1. Gestió de Dades Absents (NA)](#31-gestió-de-dades-absents-na)
- [4. Mètodes Estadístics (SAP)](#4-mètodes-estadístics-sap)
  - [4.1. Anàlisi Descriptiva](#41-anàlisi-descriptiva)
  - [4.2. Comparació de Fonts i Mètodes
    d’Imputació](#42-comparació-de-fonts-i-mètodes-dimputació)
    - [4.2.1. Aproximació 1: Comparació de dades originals `Golvin` amb
      `Vázquez-Santiago`](#421-aproximació-1-comparació-de-dades-originals-golvin-amb-vázquez-santiago)
    - [4.2.2. Aproximació 2: Comparació de dades originals `Golvin` amb
      dades imputades
      `Vazquez-Santiago`.](#422-aproximació-2-comparació-de-dades-originals-golvin-amb-dades-imputades-vazquez-santiago)
    - [4.2.3. Aproximació 3: Comparació de dades originals
      `Vázquez-Santiago` amb dades imputades
      `Vazquez-Santiago`.](#423-aproximació-3-comparació-de-dades-originals-vázquez-santiago-amb-dades-imputades-vazquez-santiago)
  - [4.3. Anàlisi de Clústers](#43-anàlisi-de-clústers)
  - [4.4. Avaluació de Càlculs d’Àrea i
    Perímetre](#44-avaluació-de-càlculs-dàrea-i-perímetre)

# 1. Introducció al Projecte

Aquest document constitueix el Pla d’Anàlisi Estadística (SAP) per al
projecte `amfiroman_ddbb`. L’objectiu principal és realitzar una anàlisi
quantitativa i comparativa de les dimensions dels amfiteatres del món
romà per identificar patrons arquitectònics, relacions dimensionals i
possibles tipologies.

## 1.1. Objectius Específics

L’anàlisi se centrarà en els següents objectius clau:

1.  **Avaluació de Fonts de Dades:** Comparar la consistència i
    fiabilitat de dues bases de dades fonamentals:

    - La base de dades de **Jean-Claude Golvin**, considerada una
      referència amb dades úniques per amfiteatre.
    - La base de dades de **Miguel Vázquez**, que agrega dades de
      múltiples fonts, presentant reptes com valors duplicats,
      discrepàncies i dades absents.

2.  **Gestió de Dades Absents:** Implementar i avaluar diferents mètodes
    d’imputació per tractar els valors perduts (`NA`) a la base de dades
    de Vázquez, amb l’objectiu de crear un conjunt de dades complet i
    robust per a l’anàlisi multivariant.

    - Mètodes d’imputació basats en estadístics de centralitat
    - Mètodes d’imputació avançats, en una primera etapa (`missForest`),
      i en una segona etapa (`MICE`).

3.  **Anàlisi de Tipologies Arquitectòniques:** Investigar l’existència
    de clústers o tipologies d’amfiteatres mitjançant un **Anàlisi de
    Clustering Jeràrquic Aglomeratiu**, basat en les seves dimensions
    principals i ràtios derivades.

4.  **Avaluació de Mètodes de Càlcul:** Analitzar i comparar diferents
    mètodes per calcular l’àrea i el perímetre de les el·lipses (arena i
    edifici), avaluant la precisió de les fórmules d’aproximació enfront
    de fórmules de referència com la de Ramanujan.

# 2. Dades

## 2.1. Fonts de Dades

L’estudi es basa en la integració i comparació de dues fonts de dades:

- **Font G (Golvin):** Base de dades de referència, caracteritzada per
  proporcionar una única mesura per a cada dimensió de cada amfiteatre.
- **Font V-S (Vázquez-Santiago):** Base de dades de compilació que
  inclou múltiples entrades per a un mateix amfiteatre, reflectint la
  variabilitat entre diferents fonts secundàries. Aquesta font conté un
  volum significatiu de dades absents.

## 2.2. Resum de Variables d’Estudi

| Categoria | Variable | Fonts | Descripció |
|----|----|----|----|
| Identificador | `index_id`, `nom` | G, V-S | Identificador numèric únic i nom. |
| Dimensió Física | `amplada_arena`, `alcada_arena` | G, V-S | Ample i llarg de l’arena (metres). |
| Dimensió Física | `amplada_general`, `alcada_general` | G, V-S | Ample i llarg total de l’edifici (metres). |
| Dimensió Física | `nombre_places` | G, V-S | Capacitat estimada de l’amfiteatre. |
| Contextual | `provincia_romana`, `pais` | G, V-S | Context geogràfic i polític. |
| Derivada | `ratio_arena`, `superficie_general` | G, V-S | Càlculs de ràtio i superfície (m²). |

**Nota Clau:** Es re-calcularan les variables derivades com la
superfície i el perímetre per garantir la consistència metodològica
entre les fonts.

## 2.3. Diccionari de Variables

La taula següent detalla les variables que s’utilitzaran en l’anàlisi.

| Variable | Tipus | Font(s) | Descripció | Notes |
|----|----|----|----|----|
| **Identificadors** |  |  |  |  |
| `index_id` | Categòrica | G, V-S | Identificador numèric únic de l’amfiteatre. | Clau primària. |
| `nom` | Categòrica | G, V-S | Nom de la localitat o amfiteatre. |  |
| **Dimensions Físiques** |  |  |  |  |
| `amplada_general` | Numèrica | G, V-S | Ample total de l’edifici (eix menor) en metres. | eix *b*. |
| `alcada_general` | Numèrica | G, V-S | Llarg total de l’edifici (eix major) en metres. | eix *a*. |
| `amplada_arena` | Numèrica | G, V-S | Ample de l’arena interior (eix menor) en metres. |  |
| `alcada_arena` | Numèrica | G, V-S | Llarg de l’arena interior (eix major) en metres. |  |
| `nombre_places` | Numèrica | G, V-S | Estimació de la capacitat de l’amfiteatre. | Utilitzada com a variable exploratòria. |
| **Variables de Context** |  |  |  |  |
| `provincia_romana` | Categòrica | V-S | Província romana històrica on es troba el jaciment. | Variable contextual. |
| `pais` | Categòrica | G, V-S | País actual on es troba el jaciment. | Variable contextual. |
| `elevation_m` | Numèrica | V-S | Elevació del jaciment sobre el nivell del mar (metres). | Utilitzada com a variable exploratòria. |
| **Variables Derivades** |  |  |  |  |
| `ratio_general` | Numèrica | Derivada | Ràtio de l’el·lipse general (`alcada_general` / `amplada_general`). | Variable per a l’anàlisi de clústers. |
| `ratio_arena` | Numèrica | Derivada | Ràtio de l’el·lipse de l’arena (`alcada_arena` / `amplada_arena`). | Variable per a l’anàlisi de clústers. |
| `superficie_general` | Numèrica | Derivada | Àrea total de l’el·lipse general (m²). | Recalculada segons la Secció 4.4. |
| `perimetre_R` | Numèrica | Derivada | Perímetre de l’el·lipse (aproximació de Ramanujan, $P_R$). | Recalculada segons la Secció 4.4. |
| `perimetre_S` | Numèrica | Derivada | Perímetre de l’el·lipse (aproximació simple, $P_1$). | Recalculada segons la Secció 4.4. |
| **Variables de l’Anàlisi** |  |  |  |  |
| `font` | Categòrica | Derivada | Identificador de la font: ‘Golvin’, ‘V-S Original’, ‘V-S Imputada’. | Clau per a les comparacions. |

# 3. Preparació de les Dades

## 3.1. Gestió de Dades Absents (NA)

La imputació de dades es realitzarà exclusivament sobre la base de dades
de Vázquez-Santiago.

- **Mètodes d’Imputació Avançats:** S’utilitzaran `missForest` (basat en
  Random Forest) i `MICE` (Imputació Múltiple per Equacions Encadenades)
  per generar un conjunt de dades imputat.
- **Avaluació de la Imputació:** Es compararà la distribució de les
  variables abans i després de la imputació mitjançant gràfics de
  densitat i proves estadístiques per avaluar l’impacte de la imputació.

# 4. Mètodes Estadístics (SAP)

## 4.1. Anàlisi Descriptiva

Es realitzarà una anàlisi descriptiva exhaustiva per a cada font de
dades (`Golvin`, `V-S Original`, `V-S Imputada`).

- **Estadístics de Resum:** Es calcularan la mitjana, mediana, desviació
  estàndard (DS), rang interquartílic (IQR) i nombre d’observacions (N)
  per a totes les variables numèriques.
- **Visualització:** S’utilitzaran histogrames, diagrames de densitat i
  diagrames de caixes (`boxplots`) per visualitzar i comparar les
  distribucions.

## 4.2. Comparació de Fonts i Mètodes d’Imputació

Es realitzarà una anàlisi inferencial per comparar les distribucions de
les variables clau entre les tres fonts. \* **Variables i Mètriques:**
\* L’anàlisi es basarà en les dades de Golvin i Vázquez-Santiago
originals i imputades. \* **Variables Principals:** `amplada_general`,
`alcada_general`, `amplada_arena`, `alcada_arena`. \* **Variables
Derivades:** `diff_amplada`, `diff_alcada`.

### 4.2.1. Aproximació 1: Comparació de dades originals `Golvin` amb `Vázquez-Santiago`

L’objectiu és trobar la diferència entre el valor constant de `Golvin` i
els valors variables de `Vázquez-Santiago` dins dels mateixos grups.

- **Variables Numèriques:** `amplada_general`, `alcada_general`,
  `amplada_arena`, `alcada_arena`.
- **Variables Categòriques:** `nom` (aparellades) o `provincia_romana`
  (independents).

| Aspecte | Decisió Final | Justificació |
|----|----|----|
| **Tipus de Test** | `wilcox_test` (Test dels Rangs Signats de Wilcoxon) | El test més adequat per a la comparació de dues mostres aparellades quan s’assumeix la no normalitat. |
| **Procediment Clau** | Test d’una mostra sobre la Diferència | Es crea una nova columna de `Diferència = col_ori_1 - col_ori_2` i es compara la mediana d’aquesta diferència amb zero (μ=0) dins de cada grup. |

### 4.2.2. Aproximació 2: Comparació de dades originals `Golvin` amb dades imputades `Vazquez-Santiago`.

L’objectiu és trobar la diferència entre el valor constant de `Golvin` i
els valors variables imputades de `Vázquez-Santiago` dins dels mateixos
grups.

- **Variables Numèriques:** `amplada_general`, `alcada_general`,
  `amplada_arena`, `alcada_arena`.
- **Variables Categòriques:** `nom` (aparellades) o `provincia_romana`
  (independents).

| Aspecte | Decisió Final | Justificació |
|----|----|----|
| **Test Global** | `friedman_test` (Test de Friedman) | Test no paramètric per comparar ≥3 mostres aparellades (Mesures Repetides). |
| **Post-hoc** | `wilcox_test` (aparellat amb ajust p) | Comparacions per parelles entre les condicions, adequat per a dades aparellades. |
| **Ajust p** | Holm (`p.adjust.method = "holm"`) | El mètode més potent per controlar l’Error de Tipus I (FWER) en comparacions múltiples. |

### 4.2.3. Aproximació 3: Comparació de dades originals `Vázquez-Santiago` amb dades imputades `Vazquez-Santiago`.

L’objectiu és trobar la diferència entre el valors diversos i originals
de `Vázquez-Santiago` i els valors variables imputades de
`Vázquez-Santiago` dins dels mateixos grups.

- **Variables Numèriques:** `amplada_general`, `alcada_general`,
  `amplada_arena`, `alcada_arena`.
- **Variables Categòriques:** `nom` (aparellades) o `provincia_romana`
  (independents).

| Aspecte | Decisió Final | Justificació |
|----|----|----|
| **Test Global** | `kruskal_test` (Test de Kruskal-Wallis) | Test no paramètric per comparar ≥3 mostres independents. |
| **Post-hoc** | `dunn_test` (Test de Dunn) | El test post-hoc dissenyat per anar després del Kruskal-Wallis. |
| **Ajust p** | Holm (`p.adjust.method = "holm"`) | Igualment recomanat per la seva potència i control de l’error. |

## 4.3. Anàlisi de Clústers

S’aplicarà un **Anàlisi de Clustering Jeràrquic Aglomeratiu** per
identificar tipologies d’amfiteatres.

- **Variables i Mètriques:**
  - L’anàlisi es basarà en les dades de Vázquez-Santiago imputades i
    normalitzades (estandaritzades).
  - **Variables Principals:** `amplada_general`, `alcada_general`,
    `amplada_arena`, `alcada_arena`.
  - **Variables Exploratòries:** `ratio_general`, `ratio_arena`,
    `elevation_m`.
- **Mètriques de Distància i Agrupament:**
  - **Distàncies:** S’avaluaran la **distància Euclidiana (L2)** i la
    **distància de Manhattan (L1)**.
  - **Mètode d’Agrupament:** S’utilitzarà el mètode de **Ward (Ward’s
    minimum variance)** per minimitzar la variància intra-clúster.

## 4.4. Avaluació de Càlculs d’Àrea i Perímetre

Es recalcularan l’àrea i el perímetre per a totes les el·lipses i es
compararà la precisió de dues fórmules per al perímetre. Les
aproximacions usades han estat:

- **Àrea de l’El·lipse (A):**

Es recalcularan l’àrea i el perímetre per a totes les el·lipses i es
compararà la precisió de dues fórmules per al perímetre. Les
aproximacions usades han estat:

- **Àrea de l’El·lipse (A):**
  <span id="eq-area">$$ A = \pi \cdot \frac{a}{2} \cdot \frac{b}{2}  \qquad(1)$$</span>

- **Perímetre (Aproximació Simple, $P_1$):**
  <span id="eq-perimetre-simple">$$ P_1 = \pi \left( \frac{a}{2} + \frac{b}{2} \right)  \qquad(2)$$</span>

Les aproximacions alternatives per al seu calcul serien les següents:

- **Perímetre (Aproximació quadràtica, $P_Q$):**
  <span id="eq-perimetre-quadratica">$$ P_Q = 2 \cdot \pi \sqrt{\frac{a^2 + b^2}{2}}  \qquad(3)$$</span>

- **Perímetre (Aproximació de Ramanujan I, $P_{RI}$):**
  <span id="eq-perimetre-ramanujan_i">$$ P_{RI} = \pi [3(a+b) - \sqrt{(3a+b)(a+3b)}]  \qquad(4)$$</span>

- **Perímetre (Aproximació de Ramanujan II, $P_{RII}$):** Aquesta
  aproximació és més precisa i utilitza un paràmetre intermedi `h`.
  <span id="eq-h-ramanujan">$$ h = \frac{(a - b)^2}{(a + b)^2}  \qquad(5)$$</span>
  <span id="eq-perimetre-ramanujan_ii">$$ P_{RII} \approx \pi (a+b) \left( 1 + \frac{3h}{10 + \sqrt{4-3h}} \right)  \qquad(6)$$</span>

**Test Estadístic:** S’utilitzarà una **Prova de Wilcoxon per a Mostres
Aparellades** per avaluar la diferència sistemàtica entre les diferents
aproximacions del perímetre (p. ex., $P_1$ vs $P_{RI}$ i $P_{RII}$). \`
\# 5. Presentació de Resultats (Dashboard)

Tots els resultats visuals i tabulars seran presentats en dos dashboards
dinàmics i interactius, accessibles des de la carpeta
amphidata/projects/dashboards/.

5.1. Dashboard Exploratori (1_dashboard_exploratori.qmd)

A continuació, et presento l’estructura i el contingut complet del
fitxer Quarto (.qmd) que ja hem començat a definir, amb la lògica R per
a generar la Taula 1 i exportar-la com a CSV Aquest dashboard se
centrarà en l’anàlisi descriptiva i la validació de la preparació de les
dades.

*   Anàlisi Descriptiva (4.1): *   Taula 1: Estadístics descriptius de
les dimensions clau, agrupats per font. *   Gràfics: Histogrames,
diagrames de densitat i diagrames de caixes comparatius per font. * 
 Gestió de Dades Absents (3.1): *   Visualitzacions del patró de dades
absents. *   Gràfics de densitat superposats per avaluar la qualitat i
el biaix introduït pels mètodes d’imputació.

| Nom del Fitxer CSV | Columna | Taula al Dashboard | Contingut (SAP Secció) | Columnes Clau | Descripció (SAP) |  |
|----|----|----|----|----|----|----|
| `descriptive_stats.csv` | Columna 1 (2/3) | Taula 1 | Anàlisi Descriptiva (4.1) | font N Mitjana_Amplada Mediana_Amplada DS_Amplada Mitjana_Ratio | Presenta la Taula 1 (Estadístics de resum) i gràfics de densitat per comparar les distribucions de les dimensions clau entre les tres fonts de dades (Golvin, V-S Original, V-S Imputada). |  |
| `quality_metrics.csv` | Columan 2 (1/ 3) | \- | Gestió de Dades Absents (3.1) | \- |  |  |

5.2. Dashboard Inferencial i de Tipologies (2_dashboard_inferencial.qmd)

Aquesta és l’estructura actualitzada del fitxer, que implementa la
lògica per generar les Taules 2, 3 i 5 (.csv) i els gràfics de clústers
i Bland-Altman, Aquest dashboard se centrarà en la presentació dels
resultats inferencials, de clústers i d’avaluació de mètodes.

*   Comparació de Fonts (4.2): *   Taules 2 i 3: Resultats dels tests
globals (Friedman/Kruskal-Wallis) i de les comparacions post-hoc
ajustades (Holm). *   Gràfic: Diagrames de violí per comparar la
densitat de les variables entre fonts. *   Anàlisi de Clústers (4.3): * 
 Taula 4: Característiques mitjanes de les variables per a cada clúster
identificat. *   Gràfics: Dendrograma i Gràfic de dispersió (PCA Biplot)
per visualitzar els clústers. *   Avaluació de Càlculs (4.4): *   Taula
5: Resultats de la Prova de Wilcoxon aparellada comparant $\text{P}_R$ i
$\text{P}_1$. \*   Gràfic: Gràfic de Bland-Altman per visualitzar
l’acord i el biaix entre els dos mètodes de càlcul del perímetre. (la
ràtio general) mitjançant un diagrama de caixes.

| Nom del Fitxer CSV | Columna | Taula al Dashboard | Contingut (SAP Secció) | Columnes Clau | Descripció (SAP) |  |
|----|----|----|----|----|----|----|
| `wilcox_results.csv` | Columna 1 (2/3) | Taules 2 i 3 | Comparació de Fonts (4.2.2) | Test (Friedman o Wilcoxon) chisq (o V) p.adj (Post-Hoc). | \- |  |
| `cluster_characteristics.csv` | Columna 2 (1/3) | Taula 4 | Anàlisi de Clústers (4.3) | cluster_id N_observacionsMitjana_Amplada_General Mitjana_Ratio_Arena | \- |  |
| `perimeter_comparison.csv` | Columna 3 (1/3) | Taula 5 | Avaluació de Càlculs (4.4) | Comparacio (PRII vs P1) N V (Estadístic de Wilcoxon) Eff_r Signif. | \- |  |

Aquest fitxer SAP_Amfiteatres.qmd és ara el teu document mestre que
defineix l’abast i la metodologia, i fa referència explícita als dos
dashboards que generaràs.

Quin dels dos dashboards vols començar a construir ara mateix? Et puc
ajudar amb el codi R i Quarto per al Dashboard Exploratori o el
Dashboard Inferencial.
