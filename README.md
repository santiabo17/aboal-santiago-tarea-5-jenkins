# 🚀 Pipeline automatizado de pruebas de rendimiento con JMeter

## Objetivo
Automatizar la ejecución de pruebas de rendimiento y aplicar umbrales automáticos que determinen si el sistema cumple los SLA definidos (P95 < 500 ms, tasa de error < 1%).

## Herramientas
- Docker + justb4/jmeter:5.6.3
- Bash para validación de umbrales
- HTML Report nativo de JMeter

## Configuración
- Archivo principal: `docker-compose.yml`
- Plan de prueba: `test-plans/api-performance.jmx`
- Propiedades externas: `config/test.properties`
- Script de umbrales: `config/check-thresholds.sh`

## Ejecución
```bash
docker compose up