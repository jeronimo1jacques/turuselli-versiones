# Turuselli — versiones

Este repositorio solo contiene los **paquetes compilados** de Turuselli, publicados como *Releases*.
El código fuente está en un repositorio privado. Los paquetes no contienen datos de clientes ni contraseñas.

## Instalar en una PC nueva

Abrir **PowerShell como administrador** (Inicio → escribir "PowerShell" → clic derecho →
"Ejecutar como administrador") y pegar:

```powershell
irm https://raw.githubusercontent.com/jeronimo1jacques/turuselli-versiones/main/instalar.ps1 | iex
```

Baja la última versión, verifica su huella SHA256 e instala. Alternativa manual: bajar
`Turuselli-X.Y.Z.zip` de [Releases](../../releases/latest), clic derecho → *Extraer todo* →
doble clic en `INSTALAR.bat`.

## Actualizar

En la PC del salón: doble clic en **ACTUALIZAR TURUSELLI** (Escritorio). Consulta el último release,
verifica la huella e instala la versión nueva, con vuelta atrás automática si algo falla.

## Contenido de cada release

`Turuselli-X.Y.Z.zip` (programa, migrador, instalador y actualizador) y `Turuselli-X.Y.Z.zip.sha256`.
