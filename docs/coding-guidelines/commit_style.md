# Guía de estilo para Commits y Documentación

> Tomados parcialmente de [Contributing to Atom](https://github.com/atom/atom/blob/master/CONTRIBUTING.md)

En esta sección, hablaremos de como documentar los commits. El propósito de estas normas es asegurar que el desarrollo pueda ser mantenible en el tiempo, se pueda hacer trazabilidad de cambios y el conocimiento del desarrollo pueda ser transferido.

## Mensajes de Commit de Git

Los lineamientos de estilo son los siguientes:

- Utilice en el mensaje del commit un emoji descriptivo:


| Emoji | Tipo      | Descripción                                                                                                                                                                                                                             |
| ----- | --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 🎨    | refactor  | cuando mejore la lógica/forma/estructura del código                                                                                                                                                                                     |
| 🛠️    | feat      | cuando agregue alguna nueva funcionalidad                                                                                                                                                                                               |
| 📝    | docs      | cuando escriba o modifique documentación                                                                                                                                                                                                            |
| 🐛    | bug       | cuando arregle un bug                                                                                                                                                                                                                   |
| 🧪    | test      | cuando agregue pruebas al código                                                                                                                                                                                                    |
| 🗑️    | remove    | cuando elimine archivos o lineas de código que no se usan en el proyecto.                                                                                                                                                                                   |
| 🔖    | bump      | cuando actualice el versionamiento semántico                                                                                                                                                                                            |
| 📌    | todo     | cuando agregue tareas a los archivos                                                                                                                                                                                                                   |
| 💄    | style     | cuando haga ajustes de formato o estilo al código. Ej: agregar cabeceras de funciones, docstrings, etc.                                                                                                                                                                                                                    |
| ⬆️    | deps-up   | cuando actualice dependencias                                                                                                                                                                                                           |
| ⬇️    | deps_down | cuando desactualice dependencias                                                                                                                                                                                                        |
| 🔀    | merge     | cuando fusione ramas                                                                                                                                                                                                                    |
- Limite la primera línea a 72 caracteres o menos.
- Refiérase a Pull Requests o Issues libremente después de la primera línea.

Por lo tanto, un buen nombramiento del commit sería de la manera:

```
git commit -m "🐛 bug: Un bug en mi config"
```

Si el cambio es más descriptivo en español, mantén la misma estructura y no olvides el emoji al principio. Por ejemplo:

```
git commit -m "📝 docs: mover opencode al módulo"
```
