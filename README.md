# Seguridad en Redes y Datos

Este repositorio contiene el proyecto final del curso **Seguridad en Redes y Datos (SDR)**, realizado por **Alexis D’Andrea** y **Nicolas Martins**.

## 📌 Objetivo

Diseñar e implementar una arquitectura segura en la nube (AWS) con foco en buenas prácticas, automatización e implementación de soluciones como WAF, SIEM, hardening y autenticación federada.

## Arquitectura Implementada

![Diagrama AWS](https://github.com/adandrea8/Obligatorio-SRD/blob/main/anexo/Diagrama-SRD.jpg)


## 🧩 Componentes del proyecto

- **Terraform:** Automatización del despliegue de infraestructura.
- **WAF con Cloudflare:** Reglas personalizadas para mitigar ataques comunes.
- **Wazuh (SIEM):** Monitoreo, detección y respuestas automáticas ante amenazas.
- **Hardening:** Aplicación de recomendaciones del CIS Benchmark con OpenSCAP.
- **Autenticación Federada:** Integración con Google para login en WordPress.

## 📁 Estructura

- `terraform/`: Código de infraestructura como código.
- `waf/`: Reglas aplicadas en Cloudflare.
- `siem/`: Configuraciones de Wazuh y reglas YARA.
- `hardening/`: Scripts y configuración con OpenSCAP.
- `autenticacion/`: Pasos para federación de identidad en WordPress.
- `anexo/`: Instalación y configuración de WordPress, declaración de autoría.

## 📚 Bibliografía

Se puede consultar en la [bibliografía](anexo/bibliografia.md) con todos los recursos utilizados.

---

> ⚠️ Este proyecto fue realizado únicamente con fines académicos.
