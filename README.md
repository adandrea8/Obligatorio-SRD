# Seguridad en Redes y Datos

Este repositorio contiene el proyecto final del curso **Seguridad en Redes y Datos (SDR)**, realizado por **Alexis D’Andrea** y **Nicolas Martins**.

## 📌 Objetivo

Diseñar e implementar una arquitectura segura en la nube (AWS) con foco en buenas prácticas, automatización e implementación de soluciones como WAF, SIEM, hardening y autenticación federada.

## Arquitectura Implementada

![Diagrama AWS](https://github.com/adandrea8/Obligatorio-SRD/blob/main/anexo/Diagrama-SRD.jpg)


### Jump-SRV
Este será nuestro servidor de salto, se encuentra en una subred pública, para que los administradores
puedan acceder a esta máquina y luego conectarse para administrar todos los equipos de la red, de
manera segura, sin exponer directamente esos recursos a internet.
Esto se logra gracias a que sus security groups que permiten el acceso a la máquina de salto solo
desde IPs específicas (las de los administradores) para asegurar que el acceso a cada equipo de la
red esté restringido.
### WAF

El Web Application Firewall se ubica aquí para filtrar el tráfico entrante y proteger contra ataques
de aplicaciones web como SQL Injection, Cross-Site Scripting (XSS), etc, siendo una de las
principales barreras frente ataques a nuestra web. Luego el tráfico podrá pasar hacia el Application
Load Balancer, permitiendo solo tráfico HTTP/HTTPS desde el WAF.
Nota: En este caso se muestra un WAF interno en la infraestructura, pero en realidad se utilizó
Cloudflare, debido a las limitaciones de nuestras cuentas de AWS.

### WEB
Los servidores de la aplicación web se encuentran en esta subred privada y están configurados en
un Auto Scaling Group para ajustar automáticamente la capacidad en función de la demanda. Estos
servidores solo podrán recibir peticiones HTTP/HTTPS desde el load balancer que distribuirá el
tráfico entre los dos.

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
