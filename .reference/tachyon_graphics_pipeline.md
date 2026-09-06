# Tachyon Graphics & Shader Pipeline (Minecraft 1.21.3)

Dieses Dokument fasst die essenziellen technischen Fallstricke und Hacks zusammen, die wir entwickelt haben, um vorkompilierte SPIR-V-Binaries (aus Mojo) direkt in die Vanilla-Post-Processing-Pipeline von Minecraft einzuschleusen.

## 1. Das "Binding" & Reflection-Problem (Unsichtbare Variablen)
**Hintergrund:** SPIR-V-Shader erzwingen feste Bindings (z. B. `layout(binding = 0)`). 
**Problem:** Wenn ein Binding im SPIR-V fest verankert ist, versteckt der OpenGL-Treiber (insb. NVIDIA) diese Variable vor der automatischen Reflection (`glGetUniformLocation` / `glGetUniformBlockIndex`). Minecraft denkt, die Variable existiert nicht, und bricht das Setup ab.
**Lösung (Samplers):**
- Wir fälschen die OpenGL-Antwort per Mixin (`GlStateManagerMixin`). 
- Wenn Minecraft nach `InSampler` fragt, geben wir als Fake-Antwort `9999` zurück. Minecraft registriert den Sampler und weist ihm Texture-Unit 0 zu (was perfekt zum SPIR-V `binding=0` passt).

## 2. Unveränderliche Uniform Buffers (UBOs)
**Hintergrund:** Uniforms wie `Time` werden in modernen Shadern über UBOs (Speicherblöcke) übertragen.
**Problem:** Wenn Minecraft in der `main.json` eine Uniform mit einem Standardwert (z.B. `"value": 0.0`) findet, legt es den GPU-Speicher als **schreibgeschützt (immutable)** an. Jeder Versuch, diesen aus Java (z.B. per `.map()`) für dynamische Updates (Zeit/Wobble) zu öffnen, wirft eine `IllegalStateException` oder OpenGL-Fehler.
**Lösung (`PostPassTimeMixin`):**
- Wir fangen den Moment ab, in dem Minecraft den Frame baut (`addToFrame`).
- Wir nutzen Java-Reflection, um die ID von Minecrafts Buffer (`handle`) zu klauen.
- Wir löschen den unveränderlichen Buffer direkt auf der Grafikkarte (`glDeleteBuffers`) und erstellen einen neuen, dynamischen Buffer (`GL_DYNAMIC_DRAW`).
- Wir schreiben die neue ID zurück in das Java-Objekt. Updates erfolgen ab sofort per rohem `glBufferSubData`.

## 3. Der UBO Binding-Crash (Warum wir Minecrafts System umgehen)
**Hintergrund:** UBOs benötigen einen Uniform Block Index, um von Minecraft gebunden zu werden.
**Problem:** Anders als bei Samplern (siehe Punkt 1) können wir Minecraft hier *keine* Fake-ID (`9999`) unterschieben. Minecraft versucht nämlich später, die Größe des Blocks abzufragen (`glGetActiveUniformBlockiv`). Eine Fake-ID führt hier zu schweren OpenGL-Crashes (`GL_INVALID_VALUE`) und bricht die gesamte Render-Pipeline.
**Lösung (`GlCommandEncoderMixin`):**
- Wir verzichten darauf, Minecraft den UBO überhaupt bekannt zu machen (er bleibt "unsichtbar").
- Stattdessen klinken wir uns exakt vor dem Zeichenbefehl (`executeDraw`) ein.
- Wir zwingen die Grafikkarte per `GL30.glBindBufferBase(GL_UNIFORM_BUFFER, 0, TachyonUboHandle)`, unseren Buffer auf Port 0 zu legen, exakt in der Millisekunde, bevor das Bild gezeichnet wird.

## 4. Schwarzer Bildschirm bei F3 (Der Alpha-Bug)
**Hintergrund:** Minecrafts Ingame-Overlay (F3) zeichnet Schriften über das fertige Bild.
**Problem:** Das Font-Rendering benötigt eine korrekte Alpha-Kanal-Mischung (Blending). Wenn unser Post-Processing-Shader stumpf `alpha = 1.0` (komplett undurchsichtig) für den gesamten Bildschirm zurückgibt, wird die Schrift-Mischung zerstört und der Bildschirm wird schwarz.
**Lösung:**
- Im Shader den Alpha-Wert des ursprünglichen Framebuffers (`color[3]`) auslesen und unverändert wieder zurückgeben.
