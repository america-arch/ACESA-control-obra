# ACESA Control de Obra — MVP v1

Aplicación web responsive (React + Vite + Supabase) con inicio de sesión, catálogo de obras, reportes diarios, fotografías privadas, panel de seguimiento, exportación CSV y compartir resumen por WhatsApp.

## Puesta en marcha
1. Instala Node.js 20 o superior.
2. Crea un proyecto en https://supabase.com y abre SQL Editor. Ejecuta `schema.sql`.
3. En Supabase > Authentication > Users crea un usuario de administración (correo y contraseña).
4. En SQL Editor, ejecuta la instrucción final comentada en `schema.sql`, sustituyendo el UUID del usuario. Para supervisores, crea usuarios en Authentication y añade sus perfiles con `role='supervisor'`.
5. Copia `.env.example` a `.env` y pega la URL y la clave **pública** (anon/publishable) del proyecto desde Supabase. Nunca uses la service_role/secret key en el navegador.
6. Ejecuta `npm install` y `npm run dev`. Abre la URL indicada.
7. Para publicar, ejecuta `npm run build` y despliega `dist/` en Netlify o Vercel con las variables VITE_SUPABASE_URL y VITE_SUPABASE_ANON_KEY configuradas. Usa HTTPS para instalación móvil.

## Flujo
- Administrador crea obras.
- Supervisores registran jornadas, avance, actividades, faltantes y fotografías.
- Panel muestra avance programado de cada obra y avance real del último reporte, historial, evidencias privadas y botón WhatsApp.
- WhatsApp abre un mensaje prellenado; **no envía automáticamente** ni adjunta las fotos. Comparte las fotos por separado desde el celular si corresponde.

## Límites de esta versión
- El avance programado se fija al crear la obra; aún no existe cronograma por partidas ni Gantt.
- Todos los usuarios autorizados pueden ver todos los proyectos y reportes; para clientes o contratistas externos se recomienda acceso segmentado por obra antes de producción.
- Los reportes de un mismo usuario/obra/fecha se actualizan al guardar; las fotos anteriores se conservan.
- El panel carga hasta 500 reportes recientes; añadir paginación al escalar.
- Sin modo sin conexión, push, geolocalización ni automatización de WhatsApp.
- Antes de producción: revisar permisos, copias de seguridad, políticas de retención de fotos y pruebas con usuarios reales.
