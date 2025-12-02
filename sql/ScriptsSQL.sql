#Análise 1: Estatísticas de População
SELECT 
    MIN(populacao_2024) as pop_minima,
    MAX(populacao_2024) as pop_maxima,
    ROUND(AVG(populacao_2024), 0) as pop_media,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY populacao_2024) as pop_mediana,
    SUM(populacao_2024) as pop_total_brasil
FROM municipio;

#Análise 2: Estatísticas de Frota Total
SELECT 
    MIN(total) as frota_minima,
    MAX(total) as frota_maxima,
    ROUND(AVG(total), 0) as frota_media,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total) as frota_mediana,
    SUM(total) as frota_total_brasil
FROM frota;

#Análise 3: Top 10 municípios por população
SELECT nome, uf, populacao_2024 
FROM municipio 
ORDER BY populacao_2024 DESC 
LIMIT 10;

#Análise 4: Top 10 municípios por frota
SELECT municipio, uf, total as frota_total
FROM frota 
ORDER BY total DESC 
LIMIT 10;

#Análise 5: Distribuição por tipo de veículo (Brasil)
SELECT 
    SUM(automovel) as total_automoveis,
    SUM(motocicleta) as total_motocicletas,
    SUM(caminhao) as total_caminhoes,
    SUM(caminhonete) as total_caminhonetes,
    SUM(onibus) as total_onibus,
    ROUND(100.0 * SUM(automovel) / SUM(total), 2) as perc_automoveis,
    ROUND(100.0 * SUM(motocicleta) / SUM(total), 2) as perc_motos
FROM frota;

#Análise 6: Dados por UF (IMPORTANTE!)
SELECT 
    m.uf,
    COUNT(DISTINCT m.ibge_id) as num_municipios,
    SUM(m.populacao_2024) as pop_total,
    ROUND(AVG(m.populacao_2024), 0) as pop_media,
    SUM(f.total) as frota_total,
    ROUND(AVG(f.total), 0) as frota_media,
    ROUND(SUM(f.total)::NUMERIC / SUM(m.populacao_2024), 3) as veiculos_per_capita_uf
FROM municipio m
LEFT JOIN frota f ON m.ibge_id = f.ibge_id
GROUP BY m.uf
ORDER BY pop_total DESC;



#Análise 7: Veículos per capita - Top 10 municípios
SELECT 
    m.nome,
    m.uf,
    m.populacao_2024,
    f.total as frota_total,
    ROUND(f.total::NUMERIC / m.populacao_2024, 3) as veiculos_per_capita
FROM municipio m
JOIN frota f ON m.ibge_id = f.ibge_id
WHERE m.populacao_2024 > 0
ORDER BY veiculos_per_capita DESC
LIMIT 10;

#Análise 8: Municípios com menor taxa de motorização (Bottom 10)
SELECT 
    m.nome,
    m.uf,
    m.populacao_2024,
    f.total as frota_total,
    ROUND(f.total::NUMERIC / m.populacao_2024, 3) as veiculos_per_capita
FROM municipio m
JOIN frota f ON m.ibge_id = f.ibge_id
WHERE m.populacao_2024 > 10000
ORDER BY veiculos_per_capita ASC
LIMIT 10;

#Análise 9: Correlação entre população e tipos de veículos
SELECT 
    CASE 
        WHEN m.populacao_2024 < 5000 THEN '1. Até 5 mil'
        WHEN m.populacao_2024 < 20000 THEN '2. 5-20 mil'
        WHEN m.populacao_2024 < 50000 THEN '3. 20-50 mil'
        WHEN m.populacao_2024 < 100000 THEN '4. 50-100 mil'
        ELSE '5. Mais de 100 mil'
    END as faixa_populacional,
    COUNT(*) as num_municipios,
    ROUND(AVG(f.total::NUMERIC / m.populacao_2024), 3) as veiculos_per_capita_medio,
    ROUND(AVG(f.automovel::NUMERIC / f.total * 100), 2) as perc_medio_automoveis,
    ROUND(AVG(f.motocicleta::NUMERIC / f.total * 100), 2) as perc_medio_motos
FROM municipio m
JOIN frota f ON m.ibge_id = f.ibge_id
WHERE m.populacao_2024 > 0 AND f.total > 0
GROUP BY faixa_populacional
ORDER BY faixa_populacional;

#Análise 10: Identificar outliers - Municípios com frotas desproporcionais
SELECT 
    m.nome,
    m.uf,
    m.populacao_2024,
    f.total as frota_total,
    ROUND(f.total::NUMERIC / m.populacao_2024, 3) as veiculos_per_capita,
    CASE 
        WHEN f.total::NUMERIC / m.populacao_2024 > 1.0 THEN 'Frota > População'
        WHEN f.total::NUMERIC / m.populacao_2024 < 0.1 THEN 'Frota muito baixa'
        ELSE 'Normal'
    END as classificacao
FROM municipio m
JOIN frota f ON m.ibge_id = f.ibge_id
WHERE m.populacao_2024 > 5000
AND (f.total::NUMERIC / m.populacao_2024 > 1.0 OR f.total::NUMERIC / m.populacao_2024 < 0.1)
ORDER BY veiculos_per_capita DESC;

#Análise 11: Proporção de motocicletas vs automóveis por região
SELECT 
    CASE 
        WHEN m.uf IN ('SP','RJ','MG','ES') THEN 'Sudeste'
        WHEN m.uf IN ('RS','SC','PR') THEN 'Sul'
        WHEN m.uf IN ('BA','SE','AL','PE','PB','RN','CE','PI','MA') THEN 'Nordeste'
        WHEN m.uf IN ('GO','MT','MS','DF') THEN 'Centro-Oeste'
        WHEN m.uf IN ('AM','RR','AP','PA','TO','RO','AC') THEN 'Norte'
    END as regiao,
    SUM(f.automovel) as total_automoveis,
    SUM(f.motocicleta) as total_motos,
    ROUND(SUM(f.motocicleta)::NUMERIC / SUM(f.automovel), 3) as razao_motos_carros,
    ROUND(100.0 * SUM(f.motocicleta) / (SUM(f.automovel) + SUM(f.motocicleta)), 2) as perc_motos
FROM municipio m
JOIN frota f ON m.ibge_id = f.ibge_id
GROUP BY regiao
ORDER BY perc_motos DESC;

#Análise 12: Verificar dados faltantes/inconsistências
SELECT 
    'Municípios sem frota' as problema,
    COUNT(*) as quantidade
FROM municipio m
LEFT JOIN frota f ON m.ibge_id = f.ibge_id
WHERE f.ibge_id IS NULL

UNION ALL

SELECT 
    'Municípios com população zero' as problema,
    COUNT(*) as quantidade
FROM municipio
WHERE populacao_2024 = 0 OR populacao_2024 IS NULL

UNION ALL

SELECT 
    'Frotas com total zero' as problema,
    COUNT(*) as quantidade
FROM frota
WHERE total = 0 OR total IS NULL;
