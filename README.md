# Copiadora Grafiplot - Sistema de Seguimiento de Trabajos con QR Físicos

Aplicación Web Progresiva (SPA) moderna desarrollada para la gestión eficiente de trabajos de fotocopiado, impresión y engargolado mediante etiquetas con códigos QR físicos y sincronización en la nube con Supabase.

> 🚀 **Última actualización de despliegue**: 2026-08-16

---

## 🌟 Características Principales

1. **Gestión de Cuentas y Boletas con QR Físico:**
   - Cada etiqueta QR adhesiva contiene una URL única (`https://scanerqrsales.grafiplotvasquez.lat/t/7KF2PX8A`).
   - Al escanear la etiqueta por **primera vez** (`status = 'unused'`), la app permite crear un **Nuevo Trabajo** o vincularla a un **Trabajo Existente**.
   - Al escanearla **después de asignada** (`status = 'assigned'`), abre directamente la **Ficha del Trabajo** mostrando cliente, servicios, desglose de precios, total y el progreso en tiempo real.

2. **Reutilización de Etiquetas Físicas ("Liberar QR"):**
   - Una vez finalizado y entregado un trabajo, el operador puede presionar **"Liberar QR"**.
   - El código vuelve a estar libre (`status = 'unused'`) para volver a pegarse en otra boleta o sobre físico.

3. **Escáner de Cámara Integrado:**
   - Lector QR veloz compatible con cámaras de celulares (Android / iOS) y webcams de laptops sin requerir aplicaciones externas.

4. **Notificaciones Automáticas por WhatsApp:**
   - Botón directo para enviar mensajes a clientes informándoles sobre el estado de su pedido (ej. *¡LISTO PARA RECOGER!*) con enlace directo de seguimiento.

5. **Estudio de Impresión de Etiquetas QR:**
   - Herramienta para generar lotes de tokens (12, 24, 48 o 96 etiquetas) y formato de impresión optimizado (`@media print`) para pliegos de etiquetas adhesivas.

6. **Funciona con Supabase & Modo Demo Offline:**
   - Integración nativa con Supabase (Auth, RLS, base de datos).
   - Incluye un **Modo Demo Local** interactivo (almacenamiento `localStorage`) para probar todas las funciones inmediatamente sin necesidad de configuración previa.

---

## 🚀 Guía de Configuración e Instalación

### 1. Base de Datos en Supabase
1. Ingresa a tu panel de control de [Supabase](https://supabase.com/).
2. Abre el **SQL Editor** de tu proyecto.
3. Copia el contenido del archivo `supabase_schema.sql` e ejecútalo.
4. Obtén tu **Project URL** y tu **Anon Public Key** en `Project Settings -> API`.

### 2. Configurar en la Aplicación Web
1. Abre la aplicación en tu navegador.
2. Haz clic en el ícono de **Configuración (Engranaje)** en la esquina superior derecha.
3. Ingresa tu **Supabase Project URL** y **Supabase Anon Key** y haz clic en **Guardar y Conectar**.

---

## 📁 Estructura del Proyecto

```
spacelabsscanqr/
├── index.html              # HTML5 SPA principal con vistas y modales
├── 404.html                # Redireccionador de rutas para GitHub Pages SPA (/t/{token})
├── CNAME                   # Configuración del dominio personalizado (scanerqrsales.grafiplotvasquez.lat)
├── supabase_schema.sql     # Script SQL con esquemas, funciones PL/pgSQL e índices
├── css/
│   └── styles.css          # Sistema de diseño, tema oscuro premium y estilos de impresión
└── js/
    ├── config.js           # Manejo de credenciales de Supabase
    ├── supabaseClient.js   # Inicializador del cliente Supabase JS
    └── app.js              # Lógica principal, enrutador, escáner y flujo de trabajo
```

---

## 🖨️ Formato de Impresión de Etiquetas QR

En la pestaña **Generar QR**, selecciona la cantidad de etiquetas que deseas generar en la base de datos y presiona **Imprimir Pliego Ahora** (`Ctrl + P`). Las etiquetas se ajustarán automáticamente en una grilla lista para papel adhesivo.
