# Pla d’Anàlisi Estadística (SAP)
Miquel Vàzquez-Santiago
2025-10-01

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

    -   La base de dades de **Jean-Claude Golvin**, considerada una
        referència amb dades úniques per amfiteatre.
    -   La base de dades de **Miguel Vázquez**, que agrega dades de
        múltiples fonts, presentant reptes com valors duplicats,
        discrepàncies i dades absents.

2.  **Gestió de Dades Absents:** Implementar i avaluar diferents mètodes
    d’imputació per tractar els valors perduts (`NA`) a la base de dades
    de Vázquez, amb l’objectiu de crear un conjunt de dades complet i
    robust per a l’anàlisi multivariant.

    -   Mètodes d’imputació basats en estadístics de centralitat
    -   Mètodes d’imputació avançats, en una primera etapa
        (`missForest`), i en una segona etapa (`MICE`).

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

-   **Font G (Golvin):** Base de dades de referència, caracteritzada per
    proporcionar una única mesura per a cada dimensió de cada
    amfiteatre.
-   **Font V-S (Vázquez-Santiago):** Base de dades de compilació que
    inclou múltiples entrades per a un mateix amfiteatre, reflectint la
    variabilitat entre diferents fonts secundàries. Aquesta font conté
    un volum significatiu de dades absents.

## 2.2. Resum de Variables d’Estudi

<table>
<colgroup>
<col style="width: 25%" />
<col style="width: 25%" />
<col style="width: 25%" />
<col style="width: 25%" />
</colgroup>
<thead>
<tr>
<th>Categoria</th>
<th>Variable</th>
<th>Fonts</th>
<th>Descripció</th>
</tr>
</thead>
<tbody>
<tr>
<td>Identificador</td>
<td><code>index_id</code>, <code>nom</code></td>
<td>G, V-S</td>
<td>Identificador numèric únic i nom.</td>
</tr>
<tr>
<td>Dimensió Física</td>
<td><code>amplada_arena</code>, <code>alcada_arena</code></td>
<td>G, V-S</td>
<td>Ample i llarg de l’arena (metres).</td>
</tr>
<tr>
<td>Dimensió Física</td>
<td><code>amplada_general</code>, <code>alcada_general</code></td>
<td>G, V-S</td>
<td>Ample i llarg total de l’edifici (metres).</td>
</tr>
<tr>
<td>Dimensió Física</td>
<td><code>nombre_places</code></td>
<td>G, V-S</td>
<td>Capacitat estimada de l’amfiteatre.</td>
</tr>
<tr>
<td>Contextual</td>
<td><code>provincia_romana</code>, <code>pais</code></td>
<td>G, V-S</td>
<td>Context geogràfic i polític.</td>
</tr>
<tr>
<td>Derivada</td>
<td><code>ratio_arena</code>, <code>superficie_general</code></td>
<td>G, V-S</td>
<td>Càlculs de ràtio i superfície (m²).</td>
</tr>
</tbody>
</table>

**Nota Clau:** Es re-calcularan les variables derivades com la
superfície i el perímetre per garantir la consistència metodològica
entre les fonts.

## 2.3. Diccionari de Variables

La taula següent detalla les variables que s’utilitzaran en l’anàlisi.

<table>
<colgroup>
<col style="width: 20%" />
<col style="width: 20%" />
<col style="width: 20%" />
<col style="width: 20%" />
<col style="width: 20%" />
</colgroup>
<thead>
<tr>
<th>Variable</th>
<th>Tipus</th>
<th>Font(s)</th>
<th>Descripció</th>
<th>Notes</th>
</tr>
</thead>
<tbody>
<tr>
<td><strong>Identificadors</strong></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td><code>index_id</code></td>
<td>Categòrica</td>
<td>G, V-S</td>
<td>Identificador numèric únic de l’amfiteatre.</td>
<td>Clau primària.</td>
</tr>
<tr>
<td><code>nom</code></td>
<td>Categòrica</td>
<td>G, V-S</td>
<td>Nom de la localitat o amfiteatre.</td>
<td></td>
</tr>
<tr>
<td><strong>Dimensions Físiques</strong></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td><code>amplada_general</code></td>
<td>Numèrica</td>
<td>G, V-S</td>
<td>Ample total de l’edifici (eix menor) en metres.</td>
<td>eix <em>b</em>.</td>
</tr>
<tr>
<td><code>alcada_general</code></td>
<td>Numèrica</td>
<td>G, V-S</td>
<td>Llarg total de l’edifici (eix major) en metres.</td>
<td>eix <em>a</em>.</td>
</tr>
<tr>
<td><code>amplada_arena</code></td>
<td>Numèrica</td>
<td>G, V-S</td>
<td>Ample de l’arena interior (eix menor) en metres.</td>
<td></td>
</tr>
<tr>
<td><code>alcada_arena</code></td>
<td>Numèrica</td>
<td>G, V-S</td>
<td>Llarg de l’arena interior (eix major) en metres.</td>
<td></td>
</tr>
<tr>
<td><code>nombre_places</code></td>
<td>Numèrica</td>
<td>G, V-S</td>
<td>Estimació de la capacitat de l’amfiteatre.</td>
<td>Utilitzada com a variable exploratòria.</td>
</tr>
<tr>
<td><strong>Variables de Context</strong></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td><code>provincia_romana</code></td>
<td>Categòrica</td>
<td>V-S</td>
<td>Província romana històrica on es troba el jaciment.</td>
<td>Variable contextual.</td>
</tr>
<tr>
<td><code>pais</code></td>
<td>Categòrica</td>
<td>G, V-S</td>
<td>País actual on es troba el jaciment.</td>
<td>Variable contextual.</td>
</tr>
<tr>
<td><code>elevation_m</code></td>
<td>Numèrica</td>
<td>V-S</td>
<td>Elevació del jaciment sobre el nivell del mar (metres).</td>
<td>Utilitzada com a variable exploratòria.</td>
</tr>
<tr>
<td><strong>Variables Derivades</strong></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td><code>ratio_general</code></td>
<td>Numèrica</td>
<td>Derivada</td>
<td>Ràtio de l’el·lipse general (<code>alcada_general</code> /
<code>amplada_general</code>).</td>
<td>Variable per a l’anàlisi de clústers.</td>
</tr>
<tr>
<td><code>ratio_arena</code></td>
<td>Numèrica</td>
<td>Derivada</td>
<td>Ràtio de l’el·lipse de l’arena (<code>alcada_arena</code> /
<code>amplada_arena</code>).</td>
<td>Variable per a l’anàlisi de clústers.</td>
</tr>
<tr>
<td><code>superficie_general</code></td>
<td>Numèrica</td>
<td>Derivada</td>
<td>Àrea total de l’el·lipse general (m²).</td>
<td>Recalculada segons la Secció 4.4.</td>
</tr>
<tr>
<td><code>perimetre_R</code></td>
<td>Numèrica</td>
<td>Derivada</td>
<td>Perímetre de l’el·lipse (aproximació de Ramanujan, <span
class="math inline"><em>P</em><sub><em>R</em></sub></span>).</td>
<td>Recalculada segons la Secció 4.4.</td>
</tr>
<tr>
<td><code>perimetre_S</code></td>
<td>Numèrica</td>
<td>Derivada</td>
<td>Perímetre de l’el·lipse (aproximació simple, <span
class="math inline"><em>P</em><sub>1</sub></span>).</td>
<td>Recalculada segons la Secció 4.4.</td>
</tr>
<tr>
<td><strong>Variables de l’Anàlisi</strong></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td><code>font</code></td>
<td>Categòrica</td>
<td>Derivada</td>
<td>Identificador de la font: ‘Golvin’, ‘V-S Original’, ‘V-S
Imputada’.</td>
<td>Clau per a les comparacions.</td>
</tr>
</tbody>
</table>

# 3. Preparació de les Dades

## 3.1. Gestió de Dades Absents (NA)

La imputació de dades es realitzarà exclusivament sobre la base de dades
de Vázquez-Santiago.

-   **Mètodes d’Imputació Avançats:** S’utilitzaran `missForest` (basat
    en Random Forest) i `MICE` (Imputació Múltiple per Equacions
    Encadenades) per generar un conjunt de dades imputat.
-   **Avaluació de la Imputació:** Es compararà la distribució de les
    variables abans i després de la imputació mitjançant gràfics de
    densitat i proves estadístiques per avaluar l’impacte de la
    imputació.

# 4. Mètodes Estadístics (SAP)

## 4.1. Anàlisi Descriptiva

Es realitzarà una anàlisi descriptiva exhaustiva per a cada font de
dades (`Golvin`, `V-S Original`, `V-S Imputada`).

-   **Estadístics de Resum:** Es calcularan la mitjana, mediana,
    desviació estàndard (DS), rang interquartílic (IQR) i nombre
    d’observacions (N) per a totes les variables numèriques.
-   **Visualització:** S’utilitzaran histogrames, diagrames de densitat
    i diagrames de caixes (`boxplots`) per visualitzar i comparar les
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

-   **Variables Numèriques:** `amplada_general`, `alcada_general`,
    `amplada_arena`, `alcada_arena`.
-   **Variables Categòriques:** `nom` (aparellades) o `provincia_romana`
    (independents).

<table>
<colgroup>
<col style="width: 8%" />
<col style="width: 24%" />
<col style="width: 67%" />
</colgroup>
<thead>
<tr>
<th>Aspecte</th>
<th>Decisió Final</th>
<th>Justificació</th>
</tr>
</thead>
<tbody>
<tr>
<td><strong>Tipus de Test</strong></td>
<td><code>wilcox_test</code> (Test dels Rangs Signats de Wilcoxon)</td>
<td>El test més adequat per a la comparació de dues mostres aparellades
quan s’assumeix la no normalitat.</td>
</tr>
<tr>
<td><strong>Procediment Clau</strong></td>
<td>Test d’una mostra sobre la Diferència</td>
<td>Es crea una nova columna de
<code>Diferència = col_ori_1 - col_ori_2</code> i es compara la mediana
d’aquesta diferència amb zero (μ=0) dins de cada grup.</td>
</tr>
</tbody>
</table>

### 4.2.2. Aproximació 2: Comparació de dades originals `Golvin` amb dades imputades `Vazquez-Santiago`.

L’objectiu és trobar la diferència entre el valor constant de `Golvin` i
els valors variables imputades de `Vázquez-Santiago` dins dels mateixos
grups.

-   **Variables Numèriques:** `amplada_general`, `alcada_general`,
    `amplada_arena`, `alcada_arena`.
-   **Variables Categòriques:** `nom` (aparellades) o `provincia_romana`
    (independents).

<table>
<colgroup>
<col style="width: 10%" />
<col style="width: 27%" />
<col style="width: 62%" />
</colgroup>
<thead>
<tr>
<th>Aspecte</th>
<th>Decisió Final</th>
<th>Justificació</th>
</tr>
</thead>
<tbody>
<tr>
<td><strong>Test Global</strong></td>
<td><code>friedman_test</code> (Test de Friedman)</td>
<td>Test no paramètric per comparar ≥3 mostres aparellades (Mesures
Repetides).</td>
</tr>
<tr>
<td><strong>Post-hoc</strong></td>
<td><code>wilcox_test</code> (aparellat amb ajust p)</td>
<td>Comparacions per parelles entre les condicions, adequat per a dades
aparellades.</td>
</tr>
<tr>
<td><strong>Ajust p</strong></td>
<td>Holm (<code>p.adjust.method = "holm"</code>)</td>
<td>El mètode més potent per controlar l’Error de Tipus I (FWER) en
comparacions múltiples.</td>
</tr>
</tbody>
</table>

### 4.2.3. Aproximació 3: Comparació de dades originals `Vázquez-Santiago` amb dades imputades `Vazquez-Santiago`.

L’objectiu és trobar la diferència entre el valors diversos i originals
de `Vázquez-Santiago` i els valors variables imputades de
`Vázquez-Santiago` dins dels mateixos grups.

-   **Variables Numèriques:** `amplada_general`, `alcada_general`,
    `amplada_arena`, `alcada_arena`.
-   **Variables Categòriques:** `nom` (aparellades) o `provincia_romana`
    (independents).

<table>
<colgroup>
<col style="width: 12%" />
<col style="width: 32%" />
<col style="width: 54%" />
</colgroup>
<thead>
<tr>
<th>Aspecte</th>
<th>Decisió Final</th>
<th>Justificació</th>
</tr>
</thead>
<tbody>
<tr>
<td><strong>Test Global</strong></td>
<td><code>kruskal_test</code> (Test de Kruskal-Wallis)</td>
<td>Test no paramètric per comparar ≥3 mostres independents.</td>
</tr>
<tr>
<td><strong>Post-hoc</strong></td>
<td><code>dunn_test</code> (Test de Dunn)</td>
<td>El test post-hoc dissenyat per anar després del Kruskal-Wallis.</td>
</tr>
<tr>
<td><strong>Ajust p</strong></td>
<td>Holm (<code>p.adjust.method = "holm"</code>)</td>
<td>Igualment recomanat per la seva potència i control de l’error.</td>
</tr>
</tbody>
</table>

## 4.3. Anàlisi de Clústers

S’aplicarà un **Anàlisi de Clustering Jeràrquic Aglomeratiu** per
identificar tipologies d’amfiteatres.

-   **Variables i Mètriques:**
    -   L’anàlisi es basarà en les dades de Vázquez-Santiago imputades i
        normalitzades (estandaritzades).
    -   **Variables Principals:** `amplada_general`, `alcada_general`,
        `amplada_arena`, `alcada_arena`.
    -   **Variables Exploratòries:** `ratio_general`, `ratio_arena`,
        `elevation_m`.
-   **Mètriques de Distància i Agrupament:**
    -   **Distàncies:** S’avaluaran la **distància Euclidiana (L2)** i
        la **distància de Manhattan (L1)**.
    -   **Mètode d’Agrupament:** S’utilitzarà el mètode de **Ward
        (Ward’s minimum variance)** per minimitzar la variància
        intra-clúster.

## 4.4. Avaluació de Càlculs d’Àrea i Perímetre

Es recalcularan l’àrea i el perímetre per a totes les el·lipses i es
compararà la precisió de dues fórmules per al perímetre. Les
aproximacions usades han estat:

-   **Àrea de l’El·lipse (A):**

    <span id="eq-area">
    $$ A = \pi \cdot \frac{a}{2} \cdot \frac{b}{2}  \qquad(1)$$
    </span>

-   **Perímetre (Aproximació Simple, *P*<sub>1</sub>):**

    <span id="eq-perimetre-simple">
    $$ P_1 = \pi \left( \frac{a}{2} + \frac{b}{2} \right)  \qquad(2)$$
    </span>

Les aproximacions alternatives per al seu calcul serien les següents:

-   **Perímetre (Aproximació quadràtica, *P*<sub>*Q*</sub>):**

    <span id="eq-perimetre-quadratica">
    $$ P_Q = 2 \cdot \pi \sqrt{\frac{a^2 + b^2}{2}}  \qquad(3)$$
    </span>

-   **Perímetre (Aproximació de Ramanujan I, *P*<sub>*R**I*</sub>):**

    <span id="eq-perimetre-ramanujan_i">
    $$ P\_{RI} = \pi \[3(a+b) - \sqrt{(3a+b)(a+3b)}\]  \qquad(4)$$
    </span>

-   **Perímetre (Aproximació de Ramanujan II,
    *P*<sub>*R**I**I*</sub>):** Aquesta aproximació és més precisa i
    utilitza un paràmetre intermedi `h`.

    <span id="eq-h-ramanujan">
    $$ h = \frac{(a - b)^2}{(a + b)^2}  \qquad(5)$$
    </span>

    <span id="eq-perimetre-ramanujan_ii">
    $$ P\_{RII} \approx \pi (a+b) \left( 1 + \frac{3h}{10 + \sqrt{4-3h}} \right)  \qquad(6)$$
    </span>

**Test Estadístic:** S’utilitzarà una **Prova de Wilcoxon per a Mostres
Aparellades** per avaluar la diferència sistemàtica entre les diferents
aproximacions del perímetre (p. ex., *P*<sub>1</sub> vs
*P*<sub>*R**I*</sub> i *P*<sub>*R**I**I*</sub>). \` \# 5. Presentació de
Resultats (Dashboard)

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

<table style="width:100%;">
<colgroup>
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 14%" />
</colgroup>
<thead>
<tr>
<th>Nom del Fitxer CSV</th>
<th>Columna</th>
<th>Taula al Dashboard</th>
<th>Contingut (SAP Secció)</th>
<th>Columnes Clau</th>
<th>Descripció (SAP)</th>
<th></th>
</tr>
</thead>
<tbody>
<tr>
<td><code>descriptive_stats.csv</code></td>
<td>Columna 1 (2/3)</td>
<td>Taula 1</td>
<td>Anàlisi Descriptiva (4.1)</td>
<td>font N Mitjana_Amplada Mediana_Amplada DS_Amplada Mitjana_Ratio</td>
<td>Presenta la Taula 1 (Estadístics de resum) i gràfics de densitat per
comparar les distribucions de les dimensions clau entre les tres fonts
de dades (Golvin, V-S Original, V-S Imputada).</td>
<td></td>
</tr>
<tr>
<td><code>quality_metrics.csv</code></td>
<td>Columan 2 (1/ 3)</td>
<td>-</td>
<td>Gestió de Dades Absents (3.1)</td>
<td>-</td>
<td></td>
<td></td>
</tr>
</tbody>
</table>

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
5: Resultats de la Prova de Wilcoxon aparellada comparant
P<sub>*R*</sub> i P<sub>1</sub>. \*   Gràfic: Gràfic de Bland-Altman per
visualitzar l’acord i el biaix entre els dos mètodes de càlcul del
perímetre. (la ràtio general) mitjançant un diagrama de caixes.

<table style="width:100%;">
<colgroup>
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 14%" />
</colgroup>
<thead>
<tr>
<th>Nom del Fitxer CSV</th>
<th>Columna</th>
<th>Taula al Dashboard</th>
<th>Contingut (SAP Secció)</th>
<th>Columnes Clau</th>
<th>Descripció (SAP)</th>
<th></th>
</tr>
</thead>
<tbody>
<tr>
<td><code>wilcox_results.csv</code></td>
<td>Columna 1 (2/3)</td>
<td>Taules 2 i 3</td>
<td>Comparació de Fonts (4.2.2)</td>
<td>Test (Friedman o Wilcoxon) chisq (o V) p.adj (Post-Hoc).</td>
<td>-</td>
<td></td>
</tr>
<tr>
<td><code>cluster_characteristics.csv</code></td>
<td>Columna 2 (1/3)</td>
<td>Taula 4</td>
<td>Anàlisi de Clústers (4.3)</td>
<td>cluster_id N_observacionsMitjana_Amplada_General
Mitjana_Ratio_Arena</td>
<td>-</td>
<td></td>
</tr>
<tr>
<td><code>perimeter_comparison.csv</code></td>
<td>Columna 3 (1/3)</td>
<td>Taula 5</td>
<td>Avaluació de Càlculs (4.4)</td>
<td>Comparacio (PRII vs P1) N V (Estadístic de Wilcoxon) Eff_r
Signif.</td>
<td>-</td>
<td></td>
</tr>
</tbody>
</table>

Aquest fitxer SAP_Amfiteatres.qmd és ara el teu document mestre que
defineix l’abast i la metodologia, i fa referència explícita als dos
dashboards que generaràs.

Quin dels dos dashboards vols començar a construir ara mateix? Et puc
ajudar amb el codi R i Quarto per al Dashboard Exploratori o el
Dashboard Inferencial.
