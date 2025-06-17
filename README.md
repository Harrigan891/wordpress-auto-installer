# 🚀 Instalador automático de WordPress con Apache, MySQL y PHP

Script en bash que automatiza la instalación completa de WordPress sobre un servidor Ubuntu con pila LAMP.

📂 Requiere privilegios de superusuario (sudo).

## 🔧 ¿Qué hace este script?

- Actualiza el sistema
- Instala Apache, MySQL y PHP con los módulos necesarios
- Crea una base de datos y usuario para WordPress
- Descarga y configura WordPress
- Establece permisos y configura Apache
- Inserta claves secretas en el archivo `wp-config.php`
- Al final, deja WordPress accesible desde: `http://localhost/wordpress`

## 📌 Requisitos

- Ubuntu o Debian
- Conexión a internet
- Permisos sudo

## 📝 Uso

1. Clona este repositorio:

```bash
git clone https://github.com/tuusuario/wordpress-auto-installer.git
cd wordpress-auto-installer
