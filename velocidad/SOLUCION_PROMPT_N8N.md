# 🔧 Solución: Prompt Personalizado No Funciona

## ❌ Problema Identificado

En tu flujo de n8n, el nodo **HTTP Request** tiene:

```
prompt: {{$json.body.prompt || 'Tarjeta de regalo con flores, tonos rosas, elegante, minimalista'}}
```

**El problema:**
- Flutter envía: `{"prompt": "flores amarillas"}` → Esto llega como `$json.prompt`
- n8n busca: `$json.body.prompt` → No lo encuentra
- Resultado: Usa el fallback con "tonos rosas" → Por eso obtienes flores rosas

---

## ✅ Solución 1: Cambiar n8n (RECOMENDADO)

**En el nodo HTTP Request de n8n:**

**Cambiar de:**
```
{{$json.body.prompt || 'Tarjeta de regalo con flores, tonos rosas, elegante, minimalista'}}
```

**A:**
```
{{$json.prompt || $json.body.prompt || 'Tarjeta de regalo con flores, tonos rosas, elegante, minimalista'}}
```

**O mejor aún, si quieres que el prompt personalizado tenga prioridad:**
```
{{$json.prompt || $json.body.prompt || 'Tarjeta de regalo con flores, tonos rosas, elegante, minimalista'}}
```

**Explicación:**
- Primero intenta `$json.prompt` (lo que envía Flutter)
- Si no existe, intenta `$json.body.prompt` (por si cambias el formato)
- Si ninguno existe, usa el fallback

---

## ✅ Solución 2: Cambiar Flutter

Si prefieres mantener n8n como está, puedo modificar Flutter para enviar:

```json
{
  "body": {
    "prompt": "flores amarillas"
  }
}
```

Pero esto es menos flexible.

---

## 🎯 Recomendación

**Usa la Solución 1** (cambiar n8n) porque:
- ✅ Es más flexible
- ✅ Funciona con el código actual de Flutter
- ✅ Permite ambos formatos (`$json.prompt` y `$json.body.prompt`)
- ✅ No requiere cambios en Flutter

---

## 📝 Pasos para Arreglar en n8n

1. Abre tu workflow en n8n
2. Haz clic en el nodo **HTTP Request**
3. En el parámetro `prompt`, cambia el valor a:
   ```
   {{$json.prompt || $json.body.prompt || 'Tarjeta de regalo con flores, tonos rosas, elegante, minimalista'}}
   ```
4. Guarda el workflow
5. Activa el workflow si no está activo
6. Prueba de nuevo desde Flutter

---

## 🧪 Cómo Verificar

Después de cambiar n8n:

1. En Flutter, escribe "flores amarillas" en el prompt personalizado
2. Genera el fondo
3. Deberías obtener flores amarillas (no rosas)

**Si sigue sin funcionar:**
- Revisa los logs de n8n en "Executions"
- Verifica qué valor tiene `$json.prompt` cuando llega la petición
- Asegúrate de que el workflow esté activo

---

## ✅ Estado

- ✅ Problema identificado: n8n busca `$json.body.prompt` pero Flutter envía `$json.prompt`
- ✅ Solución propuesta: Cambiar n8n para buscar primero `$json.prompt`
- ⏳ Pendiente: Que cambies el valor en n8n

**Una vez que cambies n8n, debería funcionar perfectamente! 🎉**

