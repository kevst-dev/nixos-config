---
name: conventional-commits-custom
description: 'Generador de mensajes de commit con estilo interno: emojis, tiempo imperativo en español, trazabilidad y descripción detallada.'
---

### Instrucciones

<description>
    Este skill actúa como un asistente para redactar mensajes de commit profesionales y detallados. 
    Sigue las reglas de estilo de la organización: mensajes en español, uso obligatorio de emojis, 
    prefijos de ticket (opcional) y una explicación extendida de los cambios realizados.
</description>

### Flujo de Trabajo

1.  **Revisión:** Analiza los archivos modificados y el `git diff`.
2.  **Construcción:** Genera el título (breve) y el cuerpo (detallado) del mensaje.
3.  **Ejecución:** Genera el comando final listo para copiar y ejecutar.

### Estructura del Mensaje

<commit-structure>
    <format>
        Título: [AB#ID] <EMOJI> <TIPO>: <Descripción breve>
        Cuerpo: <Explicación detallada de los cambios y el porqué>
    </format>
    <rules>
        <language>Español (Para todo el mensaje)</language>
        <tense>Presente Imperativo (ej. "Agregar", no "Agregado")</tense>
        <length_title>Máximo 72 caracteres para el título</length_title>
        <body_content>Explicar el "qué" y el "por qué", no solo el "cómo". Puede usar viñetas.</body_content>
        <ci-skip>Incluir "[ci skip]" en el título si es solo documentación</ci-skip>
    </rules>
</commit-structure>

### Tabla de Emojis y Tipos

| Emoji | Tipo | Descripción |
| :--- | :--- | :--- |
| 🎨 | **refactor** | Mejora de lógica o estructura del código |
| 🛠️ | **feat** | Nueva funcionalidad |
| 📝 | **docs** | Documentación (añadir [ci skip]) |
| 🐛 | **bug** | Reparación de un error |
| 🧪 | **test** | Adición o modificación de pruebas |
| ✨ | **beauti** | Cambios estéticos o de linter |
| 🗑️ | **remove** | Eliminación de archivos innecesarios |
| 🔖 | **bump** | Actualización de versión semántica |
| 📌 | **todo** | Tareas pendientes dentro del código |
| ⬆️ | **deps-up** | Actualización de dependencias |
| ⬇️ | **deps_down** | Downgrade de dependencias |
| 🔀 | **merge** | Fusión de ramas |
| 🔧 | **fix** | Ajustes de formato o configuración |

### Ejemplos

<examples>
    <example>
        git commit -m "🛠️ feat: Agregar sistema de notificaciones push" \
                   -m "Se integra Firebase Cloud Messaging para enviar alertas en tiempo real. Se incluyen los servicios de registro de tokens y manejo de payloads en segundo plano."
    </example>
    <example>
        git commit -m "🐛 bug: Corregir cálculo de impuestos en el carrito" \
                   -m "Se detectó que el IVA se aplicaba doble cuando el usuario cambiaba la dirección de envío. Se ajustó la lógica en el TaxService para limpiar el estado previo."
    </example>
    <example>
        git commit -m "📝 docs: Actualizar guía de despliegue [ci skip]" \
                   -m "Se añaden los pasos necesarios para configurar las variables de entorno en el nuevo cluster de Kubernetes."
    </example>
</examples>

### Validación del Mensaje

<validation>
    <check>¿El título es conciso y usa el verbo en imperativo?</check>
    <check>¿El cuerpo explica el contexto o la razón del cambio?</check>
    <check>¿El emoji coincide con el tipo de cambio?</check>
    <check>¿Tiene "[ci skip]" si es solo documentación?</check>
</validation>

### Generación Final

El resultado debe ser el comando formateado para la terminal:
`git commit -m "<EMOJI> <TIPO>: <TITULO>" -m "<DESCRIPCION_DETALLADA>"`
