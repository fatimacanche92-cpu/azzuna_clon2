# 🔍 Debug: Prompt Personalizado vs Resultado

## ❓ Problema Reportado

**Usuario escribió:** "flores amarillas"  
**Resultado obtenido:** Imagen con flores rosas

## 🔍 Posibles Causas

### 1. **Problema en el Código Flutter** (Menos probable)

El código actual envía:
```json
{
  "prompt": "flores amarillas",
  "occasion": "valentines",
  "template": "romantic"
}
```

**Análisis:**
- ✅ El prompt personalizado se envía correctamente
- ✅ El código usa el prompt personalizado si existe
- ⚠️ Pero también envía `occasion` y `template`

### 2. **Problema en el Flujo de n8n** (Más probable)

**Posibles escenarios:**

#### Escenario A: n8n modifica el prompt
Si tu flujo de n8n está haciendo algo como:
```javascript
// En el nodo Code de n8n
const userPrompt = $input.item.json.prompt;
const occasion = $input.item.json.occasion; // "valentines"
const template = $input.item.json.template; // "romantic"

// Si n8n está agregando colores basados en occasion:
let finalPrompt = userPrompt;
if (occasion === "valentines") {
  finalPrompt = "romantic red roses, " + userPrompt; // ❌ Sobrescribe el color
}
```

#### Escenario B: n8n ignora el prompt personalizado
Si n8n está usando solo `occasion` y `template` para generar el prompt:
```javascript
// Si n8n genera su propio prompt ignorando el del usuario
const occasionPrompts = {
  "valentines": "romantic red roses, soft pink petals..."
};
const finalPrompt = occasionPrompts[occasion]; // ❌ Ignora "flores amarillas"
```

#### Escenario C: Stability AI interpreta mal
Stability AI podría estar dando más peso a palabras como "romantic" o "valentines" que a "amarillas".

## ✅ Soluciones

### Solución 1: Verificar el Flujo de n8n

**Revisa tu nodo Code en n8n:**

1. ¿Está usando `$input.item.json.prompt` directamente?
2. ¿O está generando un nuevo prompt basado en `occasion`?
3. ¿Está modificando el prompt del usuario?

**Lo que DEBERÍA hacer:**
```javascript
// Usar el prompt del usuario directamente
const prompt = $input.item.json.prompt;

// Enviar a Stability AI
return {
  json: {
    prompt: prompt // Usar tal cual viene del usuario
  }
};
```

**Lo que NO debería hacer:**
```javascript
// ❌ NO hacer esto:
const userPrompt = $input.item.json.prompt;
const occasion = $input.item.json.occasion;
const finalPrompt = `romantic ${occasion} flowers, ${userPrompt}`; // Modifica el prompt
```

### Solución 2: Modificar el Código Flutter

**Opción A: Enviar solo el prompt cuando es personalizado**
```dart
final requestBody = customPrompt != null && customPrompt.trim().isNotEmpty
    ? jsonEncode({
        'prompt': prompt, // Solo prompt personalizado
      })
    : jsonEncode({
        'prompt': prompt,
        'occasion': occasion.name,
        'template': template.name,
      });
```

**Opción B: Hacer el prompt más explícito**
```dart
final prompt = customPrompt != null && customPrompt.trim().isNotEmpty
    ? '${customPrompt.trim()}, background pattern, no text, no words, decorative floral background, high quality, 4k'
    : _generateBackgroundPrompt(occasion, template);
```

### Solución 3: Mejorar el Prompt Personalizado

Agregar instrucciones más claras al prompt:
```dart
final prompt = customPrompt != null && customPrompt.trim().isNotEmpty
    ? '${customPrompt.trim()}, exact colors as described, background pattern, no text, no words, decorative floral background, high quality, 4k'
    : _generateBackgroundPrompt(occasion, template);
```

## 🧪 Cómo Debuggear

### 1. Revisar Logs de Flutter

Cuando generes un fondo, revisa los logs:
```
🔵 Llamando a n8n webhook...
   URL: https://dynamite666.app.n8n.cloud/webhook/azzuna-card
   Prompt: flores amarillas
   Ocasión: valentines
   Template: romantic
   Prompt personalizado: Sí
```

**Si el prompt dice "flores amarillas" pero obtienes rosas, el problema está en n8n.**

### 2. Probar en Postman

Envía directamente a n8n:
```json
{
  "prompt": "flores amarillas"
}
```

**Si funciona en Postman pero no en la app, el problema está en cómo se envía.**

### 3. Revisar Logs de n8n

En n8n, ve a "Executions" y revisa:
- ¿Qué prompt recibió n8n?
- ¿Qué prompt envió a Stability AI?
- ¿Hay algún nodo Code que modifique el prompt?

## 🎯 Recomendación

**Lo más probable es que el problema esté en n8n:**

1. **Revisa tu nodo Code en n8n** - Asegúrate de que use el prompt del usuario directamente
2. **Si n8n está modificando el prompt** - Quita esa lógica cuando hay prompt personalizado
3. **Si n8n está ignorando el prompt** - Modifica el flujo para dar prioridad al prompt personalizado

**Si quieres, puedo modificar el código Flutter para:**
- Enviar solo el prompt cuando es personalizado (sin occasion/template)
- Hacer el prompt más explícito con instrucciones de color
- Agregar más logging para debuggear

¿Quieres que revise tu flujo de n8n o prefieres que modifique el código Flutter primero?

