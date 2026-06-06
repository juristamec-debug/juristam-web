$blogDir = 'c:\Users\HOLA\OneDrive\Escritorio\juristam-web\blog'
$utf8noBOM = New-Object System.Text.UTF8Encoding $false
$updated = 0; $skipped = 0; $notFound = 0

function Add-Faqs {
    param([string]$filename, [array]$qa)
    $path = Join-Path $blogDir $filename
    if (-not (Test-Path $path)) { Write-Host "NOT FOUND: $filename"; $script:notFound++; return }
    $c = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)

    # Skip if first new question already present
    if ($c -contains $qa[0].q -or $c.IndexOf($qa[0].q) -ge 0) {
        Write-Host "SKIP (exists): $filename"; $script:skipped++; return
    }

    # --- 1. Insert JSON questions into FAQPage mainEntity ---
    $tag = '<script type="application/ld+json">'
    $si = $c.IndexOf($tag); $ei = $c.IndexOf('</script>', $si)
    if ($si -ge 0) {
        $jsonBlock = $c.Substring($si + $tag.Length, $ei - $si - $tag.Length)
        # Build JSON additions
        $jsonAdd = ''
        foreach ($pair in $qa) {
            $q = $pair.q -replace '\\','\\' -replace '"','\"'
            $a = $pair.a -replace '\\','\\' -replace '"','\"'
            $jsonAdd += ',{"@type":"Question","name":"' + $q + '","acceptedAnswer":{"@type":"Answer","text":"' + $a + '"}}'
        }
        # Find second-to-last ]} in JSON block (closes mainEntity+FAQPage)
        $lastBracket  = $jsonBlock.LastIndexOf(']}')
        $faqClose     = $jsonBlock.LastIndexOf(']}', $lastBracket - 1)
        if ($faqClose -ge 0) {
            # Insert additions before the ] that closes mainEntity
            $absPos = $si + $tag.Length + $faqClose
            $c = $c.Substring(0, $absPos) + $jsonAdd + $c.Substring($absPos)
        }
    }

    # --- 2. Insert HTML <details> into faq-section ---
    $htmlAdd = ''
    foreach ($pair in $qa) {
        $htmlAdd += "`n<details>`n  <summary>" + $pair.q + "</summary>`n  <p class=`"faq-answer`">" + $pair.a + "</p>`n</details>"
    }
    # Insert before the </div> that closes the last </details> block
    $lastDetails = $c.LastIndexOf('</details>')
    if ($lastDetails -ge 0) {
        $closingDiv = $c.IndexOf('</div>', $lastDetails + 10)
        if ($closingDiv -ge 0) {
            $c = $c.Substring(0, $closingDiv) + $htmlAdd + "`n" + $c.Substring($closingDiv)
        }
    }

    [System.IO.File]::WriteAllText($path, $c, $utf8noBOM)
    Write-Host "OK: $filename"
    $script:updated++
}

# ===================== DATA =====================

Add-Faqs 'abuso-mayoria-societaria-ecuador.html' @(
    @{q='¿Cuándo una decisión de la mayoría se considera abusiva en Ecuador?';a='Cuando beneficia exclusivamente a los socios mayoritarios en perjuicio de los minoritarios y sin justificación empresarial válida. El juez evalúa caso a caso. Escríbenos: 0994859814.'},
    @{q='¿Qué pruebas necesito para demostrar abuso de mayoría?';a='Las actas de junta, los estados financieros, correspondencia interna y cualquier documento que muestre el beneficio exclusivo de los mayoritarios y el perjuicio de los demás. Escríbenos: 0994859814.'},
    @{q='¿Cuánto tiempo tengo para impugnar una decisión de junta que considero abusiva?';a='Los plazos son cortos. Debes actuar pronto después de conocer la decisión. Tu abogado determinará el plazo exacto según el tipo de acción. Escríbenos: 0994859814.'},
    @{q='¿Puedo pedir medidas cautelares mientras se resuelve el caso de abuso de mayoría?';a='Sí. Puedes solicitar la suspensión de la ejecución de la decisión impugnada mientras se tramita el proceso judicial. Escríbenos: 0994859814.'}
)

Add-Faqs 'blindaje-patrimonial-legal-ecuador.html' @(
    @{q='¿Es lo mismo blindaje patrimonial que esconder bienes?';a='No. El blindaje patrimonial legal usa instrumentos reconocidos por la ley. Esconder bienes es fraude. La diferencia es fundamental y legal. Escríbenos: 0994859814.'},
    @{q='¿Puedo hacer el blindaje después de que ya tengo deudas?';a='Si ya hay deudas, el blindaje puede ser impugnable por los acreedores como acto en fraude de acreedores. La planificación debe hacerse antes, no cuando ya hay problemas. Escríbenos: 0994859814.'},
    @{q='¿Qué herramientas legales de blindaje existen en Ecuador?';a='Fideicomisos, separación correcta de patrimonios, planificación societaria, seguros de vida y bienes en régimen de afectación. Cada una sirve para objetivos distintos. Escríbenos: 0994859814.'},
    @{q='¿El blindaje patrimonial me protege también en procesos penales?';a='Depende del tipo de proceso. Bienes en fideicomiso pueden estar protegidos en algunos escenarios. Pero el origen del patrimonio siempre puede ser investigado. Escríbenos: 0994859814.'}
)

Add-Faqs 'bloqueo-decisiones-socios-ecuador.html' @(
    @{q='¿Si la empresa está paralizada, puedo pedir al juez que nombre un administrador?';a='Sí. En casos de bloqueo grave el juez puede intervenir nombrando un administrador judicial provisional para que la empresa siga operando. Escríbenos: 0994859814.'},
    @{q='¿El bloqueo de decisiones puede llevar a la disolución de la empresa?';a='Sí. Si el bloqueo es permanente e impide el normal funcionamiento, puede ser causal de disolución judicial de la sociedad. Escríbenos: 0994859814.'},
    @{q='¿Qué diferencia hay entre bloqueo en junta y bloqueo en administración?';a='El bloqueo en junta ocurre cuando no se pueden tomar decisiones por quórum. El de administración cuando el representante legal no actúa. Cada uno tiene soluciones distintas. Escríbenos: 0994859814.'},
    @{q='¿Puedo vender mis participaciones si la empresa está bloqueada?';a='Depende de los estatutos. Si hay restricciones a la transferencia de participaciones, el bloqueo puede también dificultar la salida. Escríbenos: 0994859814.'}
)

Add-Faqs 'carga-prueba-tributaria-ecuador.html' @(
    @{q='¿Qué documentos debo conservar para la carga de la prueba tributaria?';a='Facturas, contratos, estados de cuenta, registros contables y cualquier documento que respalde tus deducciones y declaraciones. El SRI puede pedirlos hasta 6 años después. Escríbenos: 0994859814.'},
    @{q='¿Si el SRI presume una obligación, cómo la refuto?';a='Presentando los documentos que demuestren lo contrario. La presunción es válida hasta que la refutes con prueba documental suficiente. Escríbenos: 0994859814.'},
    @{q='¿Qué plazo tengo para presentar pruebas ante el SRI o el Tribunal Fiscal?';a='Los plazos varían según el proceso. En el proceso administrativo ante el SRI los plazos son más cortos que en el Tribunal Distrital de lo Fiscal. Escríbenos: 0994859814.'},
    @{q='¿Un contador puede presentar la prueba tributaria o necesito abogado?';a='Ante el SRI puede actuar el contador. Ante el Tribunal Distrital de lo Fiscal se requiere patrocinio legal. La estrategia combinada de ambos es la más efectiva. Escríbenos: 0994859814.'}
)

Add-Faqs 'coactiva-deuda-ilegal-defensa-ecuador.html' @(
    @{q='¿Cómo sé si mi coactiva tiene vicios que la hacen ilegal?';a='Revisando el título de crédito, el proceso de notificación y si se siguieron todos los pasos del procedimiento coactivo. Un abogado puede identificar esos vicios rápidamente. Escríbenos: 0994859814.'},
    @{q='¿Puedo detener una coactiva ilegal con una medida cautelar?';a='Sí. Si hay vicios claros en el proceso coactivo, puedes solicitar medidas cautelares que suspendan el cobro mientras se resuelve la impugnación. Escríbenos: 0994859814.'},
    @{q='¿La coactiva puede embargar mis bienes aunque impugne?';a='Mientras no haya una suspensión judicial, el proceso coactivo puede continuar. Por eso actuar rápido para obtener medidas cautelares es fundamental. Escríbenos: 0994859814.'},
    @{q='¿Qué plazo tengo para impugnar una coactiva?';a='Los plazos son muy cortos. En Ecuador la demanda de excepciones debe presentarse dentro de los días siguientes a la notificación del auto de pago. No esperes. Escríbenos: 0994859814.'}
)

Add-Faqs 'coactiva-ex-representante-legal-nulidad-ecuador.html' @(
    @{q='¿Cómo pruebo que ya no era representante legal cuando ocurrió la deuda?';a='Con la inscripción del cambio de representante en el Registro Mercantil y la Supercias. La fecha del cambio registrado es la que prueba tu desvinculación. Escríbenos: 0994859814.'},
    @{q='¿Si fui representante legal pero no firmé el contrato que generó la deuda, igual me cobran?';a='Depende de si el contrato fue firmado durante tu período como representante y si la deuda surgió en ese período. La fecha es el factor determinante. Escríbenos: 0994859814.'},
    @{q='¿Cuánto tarda resolver una coactiva por nulidad por ex representante?';a='Depende de la complejidad del caso y si hay apelaciones. En promedio entre 6 meses y 2 años. Mientras dura el proceso puedes solicitar medidas cautelares. Escríbenos: 0994859814.'},
    @{q='¿Si gano la nulidad de la coactiva, la empresa sigue debiendo?';a='La nulidad puede ser personal — de tu responsabilidad — sin afectar la deuda de la empresa. O puede ser de todo el proceso si hubo vicios graves. Depende del caso. Escríbenos: 0994859814.'}
)

Add-Faqs 'comercio-exterior-aduanas-ecuador.html' @(
    @{q='¿Qué es el aforo y cuántos tipos hay en Ecuador?';a='El aforo es la revisión aduanera de la mercancía. Hay cuatro tipos: canal verde (automático), amarillo (revisión documental), naranja (revisión física parcial) y rojo (revisión física completa). Escríbenos: 0994859814.'},
    @{q='¿Cuánto tiempo tengo para retirar la mercancía del puerto sin generar sobreestadía?';a='Depende del terminal. Generalmente hay entre 5 y 15 días libres. Después empiezan a correr las sobreestadías. Escríbenos: 0994859814.'},
    @{q='¿Qué pasa si importo algo sin el permiso requerido?';a='La mercancía puede ser retenida, confiscada o generar multas. Algunos productos requieren permisos del ARCSA, AGROCALIDAD u otras entidades además del SENAE. Escríbenos: 0994859814.'},
    @{q='¿El SENAE puede investigar importaciones pasadas?';a='Sí. El SENAE tiene un período de revisión posterior al despacho. Puede auditar importaciones anteriores si detecta indicios de subvaloración u otras irregularidades. Escríbenos: 0994859814.'}
)

Add-Faqs 'compliance-empresarial-ecuador.html' @(
    @{q='¿Qué empresas en Ecuador están obligadas a tener compliance?';a='Las sujetas a la Ley de Prevención de Lavado de Activos, las reguladas por la Supercias, las financieras y las que operan en sectores sensibles. La lista se amplía cada año. Escríbenos: 0994859814.'},
    @{q='¿El representante legal responde personalmente si la empresa no cumple?';a='Sí. En Ecuador el representante legal puede tener responsabilidad personal por incumplimientos que debía prevenir o reportar. Escríbenos: 0994859814.'},
    @{q='¿Cuánto cuesta implementar un programa de compliance?';a='Depende del tamaño y sector de la empresa. Juristam diseña programas adaptados a cada empresa. Consulta para un presupuesto específico. Escríbenos: 0994859814.'},
    @{q='¿El compliance protege a los directivos de responsabilidad personal?';a='Un programa de compliance bien implementado es evidencia de diligencia debida. Puede reducir significativamente la responsabilidad personal de los directivos. Escríbenos: 0994859814.'}
)

Add-Faqs 'compliance-que-es-ecuador.html' @(
    @{q='¿El compliance es lo mismo que el departamento legal de una empresa?';a='No. El departamento legal gestiona conflictos. El compliance previene que ocurran. Son funciones complementarias pero distintas. Escríbenos: 0994859814.'},
    @{q='¿Una empresa pequeña necesita compliance?';a='Si está sujeta a obligaciones de prevención de lavado de activos u otras regulaciones sectoriales, sí. El tamaño no exime de esas obligaciones. Escríbenos: 0994859814.'},
    @{q='¿Qué pasa si la Supercias hace una inspección y no tenemos compliance?';a='Puede resultar en observaciones, multas y en algunos casos en responsabilidad del representante legal. La Supercias cada vez verifica más el cumplimiento de estas obligaciones. Escríbenos: 0994859814.'},
    @{q='¿Cuánto tiempo tarda implementar un programa de compliance?';a='Depende de la complejidad. Un programa básico puede implementarse en semanas. Uno completo para empresa mediana puede tomar meses. Escríbenos: 0994859814.'}
)

Add-Faqs 'conflictos-societarios-ecuador.html' @(
    @{q='¿El mediador puede resolver conflictos societarios en Ecuador?';a='Sí. La mediación es una opción válida para resolver conflictos societarios en Ecuador. Puede ser más rápida y menos costosa que el litigio judicial. Escríbenos: 0994859814.'},
    @{q='¿Qué pasa si los estatutos no prevén cómo resolver el conflicto?';a='El juez aplica la ley societaria general. Por eso tener estatutos bien redactados desde el inicio previene muchos conflictos o facilita su resolución. Escríbenos: 0994859814.'},
    @{q='¿Cuánto tiempo puede durar un juicio por conflicto societario en Ecuador?';a='Puede durar de 1 a 3 años dependiendo de la complejidad y si hay apelaciones. Durante ese tiempo la empresa puede ver afectadas sus operaciones. Escríbenos: 0994859814.'},
    @{q='¿Puedo salir de la empresa si hay un conflicto grave?';a='Sí, pero las condiciones de salida dependen de los estatutos y el tipo de sociedad. Puede requerir liquidar las participaciones a un valor que también puede ser objeto de disputa. Escríbenos: 0994859814.'}
)

Add-Faqs 'constitucion-companias-ecuador.html' @(
    @{q='¿Cuánto tiempo tarda constituir una empresa en Ecuador?';a='Entre 2 y 6 semanas en promedio si la documentación está completa. El proceso incluye escritura pública, inscripción en el Registro Mercantil y aprobación de la Supercias. Escríbenos: 0994859814.'},
    @{q='¿Cuál es el capital mínimo para una SAS o Cía. Ltda.?';a='El capital mínimo ha variado con las reformas. Consulta los requisitos actualizados con Juristam para el tipo de sociedad que deseas constituir. Escríbenos: 0994859814.'},
    @{q='¿Puedo constituir una empresa solo o necesito un socio?';a='La SAS puede constituirse con un solo accionista. La Cía. Ltda. requiere mínimo 2 socios. Elige el tipo según tu situación. Escríbenos: 0994859814.'},
    @{q='¿Si me equivoco en los estatutos al inicio, puedo modificarlos después?';a='Sí, pero la modificación de estatutos requiere junta general, escritura pública e inscripción. Es más costoso que hacerlos bien desde el inicio. Escríbenos: 0994859814.'}
)

Add-Faqs 'contrato-fletamento-ecuador.html' @(
    @{q='¿Qué tipos de charter party existen en Ecuador?';a='Los principales son: viaje (voyage charter), tiempo (time charter) y casco desnudo (bareboat charter). Cada uno tiene implicaciones de responsabilidad muy distintas. Escríbenos: 0994859814.'},
    @{q='¿El laytime qué es y por qué genera tantos conflictos?';a='El laytime es el tiempo permitido para cargar o descargar. Cuando se excede ese tiempo empieza el demurrage. La discusión sobre cuándo empieza y qué lo suspende es la fuente más frecuente de conflictos. Escríbenos: 0994859814.'},
    @{q='¿Puedo negociar el demurrage en el charter party?';a='Sí. Es una de las cláusulas más negociables. La tasa de demurrage y las causales de suspensión pueden pactarse libremente entre las partes. Escríbenos: 0994859814.'},
    @{q='¿El charter party se rige por la ley ecuatoriana?';a='Depende de la cláusula de ley aplicable. Muchos charter parties internacionales designan ley inglesa o de otro país. Eso afecta cómo se resuelven los conflictos. Escríbenos: 0994859814.'}
)

Add-Faqs 'contrato-servicios-empresa-ecuador.html' @(
    @{q='¿Un contrato de servicios puede convertirse en relación laboral?';a='Sí. Si el contrato de servicios tiene características de dependencia laboral (horario, subordinación, exclusividad), el IESS y tribunales pueden calificarlo como relación laboral. Escríbenos: 0994859814.'},
    @{q='¿Qué cláusulas no pueden faltar en un contrato de servicios en Ecuador?';a='Objeto del servicio, plazo, precio, forma de pago, causales de terminación anticipada, confidencialidad y jurisdicción. Sin ellas el contrato puede ser ineficaz en puntos clave. Escríbenos: 0994859814.'},
    @{q='¿Un contrato de servicios verbal es válido en Ecuador?';a='Sí, pero es muy difícil de probar en caso de conflicto. Para cualquier servicio significativo, el contrato escrito es indispensable. Escríbenos: 0994859814.'},
    @{q='¿Puedo incluir una cláusula de no competencia en un contrato de servicios?';a='Sí. En contratos de servicios entre empresas o con profesionales independientes es válida. Su extensión debe ser razonable en tiempo y geografía. Escríbenos: 0994859814.'}
)

Add-Faqs 'contrato-socios-empresa-ecuador.html' @(
    @{q='¿El pacto de socios tiene el mismo valor que los estatutos?';a='Son documentos complementarios. Los estatutos son públicos y se registran. El pacto de socios es privado y regula aspectos que los estatutos no cubren o que las partes quieren mantener confidenciales. Escríbenos: 0994859814.'},
    @{q='¿Qué pasa si el pacto de socios contradice los estatutos?';a='En principio los estatutos prevalecen frente a terceros. Entre los socios, el pacto puede ser vinculante aunque contradiga los estatutos. Es una situación que conviene evitar. Escríbenos: 0994859814.'},
    @{q='¿Cuándo es más crítico tener un pacto de socios?';a='Cuando hay socios con porcentajes similares de participación (riesgo de bloqueo), cuando algún socio aporta más gestión que capital, o cuando hay socios externos que quieren liquidez futura. Escríbenos: 0994859814.'},
    @{q='¿El pacto de socios puede incluir cláusulas de salida forzada?';a='Sí. Las cláusulas drag-along (arrastre) y tag-along (acompañamiento) son comunes en pactos de socios y permiten gestionar escenarios de venta de la empresa. Escríbenos: 0994859814.'}
)

Add-Faqs 'contratos-empresariales-ecuador.html' @(
    @{q='¿Qué cláusula es la más importante en un contrato empresarial?';a='La de resolución de conflictos. Define si van a arbitraje, mediación o tribunal, y qué ley aplica. Sin ella el conflicto puede volverse muy costoso de resolver. Escríbenos: 0994859814.'},
    @{q='¿Los contratos descargados de internet tienen valor legal en Ecuador?';a='Son válidos si cumplen los requisitos del Código Civil. Pero al no estar adaptados a tu caso específico y a la ley ecuatoriana, pueden tener vacíos peligrosos. Escríbenos: 0994859814.'},
    @{q='¿Un correo electrónico puede ser un contrato válido en Ecuador?';a='Sí. Las comunicaciones electrónicas pueden constituir contratos si hay oferta, aceptación y objeto. Pero son difíciles de impugnar o defender sin términos claros. Escríbenos: 0994859814.'},
    @{q='¿Cuándo conviene ir a arbitraje en vez de a los tribunales?';a='Para contratos de alto valor, cuando necesitas confidencialidad, cuando las partes son de diferentes países o cuando necesitas un fallo rápido con ejecutabilidad internacional. Escríbenos: 0994859814.'}
)

Add-Faqs 'contratos-mal-hechos-riesgos-ecuador.html' @(
    @{q='¿Cuál es el error más frecuente en contratos empresariales en Ecuador?';a='No incluir cláusulas claras sobre qué pasa si una parte incumple. Sin eso, el afectado debe ir a juicio sin un mecanismo predefinido, lo que es costoso y lento. Escríbenos: 0994859814.'},
    @{q='¿Un contrato sin firma tiene valor en Ecuador?';a='Puede tener valor si hay otras formas de prueba de acuerdo (correos, transferencias). Pero la firma da certeza y es difícil de contradecir. Escríbenos: 0994859814.'},
    @{q='¿Si modifico un contrato verbal, eso vale legalmente?';a='Las modificaciones verbales son difíciles de probar. Todo cambio a un contrato debe documentarse por escrito con la misma forma que el contrato original. Escríbenos: 0994859814.'},
    @{q='¿Puedo salir de un contrato mal hecho antes de que me cause daños?';a='Depende de las cláusulas de terminación que tenga. Si no las tiene, salir puede generarte responsabilidad. Consulta antes de actuar. Escríbenos: 0994859814.'}
)

Add-Faqs 'cuanto-cuesta-crear-empresa-ecuador.html' @(
    @{q='¿Se puede crear una empresa en Ecuador sin capital inicial?';a='No. Todos los tipos de sociedad requieren un capital mínimo. Para SAS y Cía. Ltda. los montos actuales deben verificarse con Juristam ya que la normativa puede cambiar. Escríbenos: 0994859814.'},
    @{q='¿El capital declarado tiene que depositarse en un banco?';a='Sí. El capital debe acreditarse con un certificado bancario al momento de la escritura pública de constitución. Escríbenos: 0994859814.'},
    @{q='¿Cuánto cobran los notarios por la escritura de constitución?';a='Los notarios tienen un arancel regulado que varía según el capital de la empresa. En Juristam te informamos del costo total estimado antes de iniciar. Escríbenos: 0994859814.'},
    @{q='¿Hay costos anuales de mantenimiento de una empresa en Ecuador?';a='Sí. Incluyen la obligación de presentar estados financieros a la Supercias, los costos contables y posibles contribuciones regulatorias según el sector. Escríbenos: 0994859814.'}
)

Add-Faqs 'derecho-corporativo-empresas-ecuador.html' @(
    @{q='¿Cuándo debo consultar a un abogado corporativo?';a='Antes de constituir la empresa, al redactar contratos importantes, ante una inspección regulatoria o cuando hay conflictos entre socios. La asesoría preventiva siempre es más barata que el litigio. Escríbenos: 0994859814.'},
    @{q='¿El derecho corporativo cubre también las relaciones con empleados?';a='Parcialmente. Las relaciones laborales tienen su propio marco. El derecho corporativo se enfoca en la estructura societaria, contratos y relaciones con socios y reguladores. Escríbenos: 0994859814.'},
    @{q='¿Qué diferencia hay entre asesoría legal general y asesoría corporativa?';a='La corporativa se especializa en la estructura y operación de empresas. Entiende la dinámica de negocios y la normativa societaria que un abogado general puede no dominar con la misma profundidad. Escríbenos: 0994859814.'},
    @{q='¿Las empresas familiares necesitan asesoría corporativa?';a='Especialmente las empresas familiares. Sin estructura legal clara los conflictos familiares y empresariales se mezclan, con resultados devastadores para el negocio. Escríbenos: 0994859814.'}
)

Add-Faqs 'documentos-importacion-ecuador.html' @(
    @{q='¿Qué pasa si falta un documento al momento del despacho aduanero?';a='El SENAE puede retener la mercancía hasta que se presente el documento faltante. Mientras tanto corren sobreestadías y costos de almacenamiento. Escríbenos: 0994859814.'},
    @{q='¿Las facturas comerciales tienen requisitos específicos para Ecuador?';a='Sí. Deben incluir descripción detallada de la mercancía, precio unitario y total, país de origen y otros datos que el SENAE verifica para el aforo. Escríbenos: 0994859814.'},
    @{q='¿El certificado de origen es obligatorio para todas las importaciones?';a='No para todas, pero sí para productos que quieran beneficiarse de acuerdos comerciales o que vengan de países con los que Ecuador tiene tratados preferenciales. Escríbenos: 0994859814.'},
    @{q='¿Los documentos de importación pueden presentarse en forma digital?';a='El SENAE tiene plataforma electrónica para la declaración aduanera. Algunos documentos físicos aún se requieren en original o copia certificada. Escríbenos: 0994859814.'}
)

Add-Faqs 'errores-crear-sas-ecuador.html' @(
    @{q='¿Qué diferencia a una SAS bien constituida de una mal constituida?';a='Los estatutos. Una SAS bien constituida tiene reglas claras de gobierno, mecanismos para resolver conflictos y protecciones para los socios minoritarios. Una mal constituida carece de todo eso. Escríbenos: 0994859814.'},
    @{q='¿Puedo modificar los estatutos de la SAS después de constituirla?';a='Sí. Pero la modificación requiere junta general, escritura pública e inscripción. Es más costoso que hacerlos bien desde el inicio. Escríbenos: 0994859814.'},
    @{q='¿Qué pasa si la SAS opera sin junta anual?';a='La Supercias puede observar el incumplimiento y generar multas. Además la falta de decisiones formales puede generar disputas entre socios. Escríbenos: 0994859814.'},
    @{q='¿La SAS es mejor que la Cía. Ltda. para startups?';a='En muchos casos sí. La SAS tiene más flexibilidad en estructura de capital y gobierno. Pero la elección depende del proyecto específico y el número de socios. Escríbenos: 0994859814.'}
)

Add-Faqs 'expulsar-socio-compania-ecuador.html' @(
    @{q='¿Pueden los otros socios sacarme de la empresa sin mi consentimiento?';a='Solo bajo causales específicas y con un proceso que cumpla los estatutos y la ley. Una exclusión sin proceso puede ser impugnable. Escríbenos: 0994859814.'},
    @{q='¿Si me sacan de la empresa tengo derecho a recibir el valor de mis participaciones?';a='Sí. La exclusión da derecho a la liquidación del valor de tus participaciones conforme al valor real de la empresa, no solo al valor nominal. Escríbenos: 0994859814.'},
    @{q='¿Cómo se determina el valor de mis participaciones si me excluyen?';a='Mediante avalúo pericial. Si las partes no acuerdan el valor, el juez nombra un perito que determina el valor real de las participaciones. Escríbenos: 0994859814.'},
    @{q='¿Puedo impugnar mi exclusión mientras dura el proceso?';a='Sí. Puedes solicitar medidas cautelares para suspender los efectos de la exclusión mientras se resuelve el proceso de impugnación. Escríbenos: 0994859814.'}
)

Add-Faqs 'fideicomisos-ecuador.html' @(
    @{q='¿Qué bienes pueden ponerse en un fideicomiso en Ecuador?';a='Inmuebles, dinero, participaciones societarias, vehículos y otros activos. El fideicomiso puede recibir casi cualquier tipo de bien transferible. Escríbenos: 0994859814.'},
    @{q='¿El fideicomiso protege mis bienes de deudas futuras?';a='Si el fideicomiso fue constituido antes de la deuda y sin intención fraudulenta, sí puede proteger esos bienes. Pero los acreedores pueden atacarlo si prueban fraude. Escríbenos: 0994859814.'},
    @{q='¿Cuánto cuesta constituir un fideicomiso en Ecuador?';a='Depende del valor de los bienes y la fiduciaria elegida. Hay costos de constitución, honorarios de la fiduciaria y gastos notariales. Consulta para un estimado según tu caso. Escríbenos: 0994859814.'},
    @{q='¿El fideicomiso es lo mismo que un testamento?';a='No. El fideicomiso opera en vida y puede continuar después de la muerte. El testamento solo produce efectos al morir. Son instrumentos complementarios, no equivalentes. Escríbenos: 0994859814.'}
)

Add-Faqs 'herederos-acciones-compania-ecuador.html' @(
    @{q='¿Los herederos pueden vender las participaciones heredadas inmediatamente?';a='Depende de los estatutos. Muchas sociedades tienen restricciones a la transferencia de participaciones que los herederos deben respetar. Escríbenos: 0994859814.'},
    @{q='¿Si hay un heredero que quiere liquidar y otro que quiere seguir con la empresa?';a='Ese conflicto es frecuente y puede paralizarse la empresa. El testamento y el pacto de socios bien estructurados previenen exactamente este escenario. Escríbenos: 0994859814.'},
    @{q='¿Las participaciones heredadas generan impuesto a la herencia?';a='Sí. Como cualquier bien heredado, las participaciones societarias están sujetas al impuesto a la herencia en Ecuador según su valor. Escríbenos: 0994859814.'},
    @{q='¿Qué pasa si el heredero no quiere participar en la empresa?';a='Puede vender sus participaciones o pedir la liquidación de su parte. Los mecanismos para hacer eso dependen de los estatutos de la empresa. Escríbenos: 0994859814.'}
)

Add-Faqs 'impugnacion-juntas-generales-ecuador.html' @(
    @{q='¿Cuánto tiempo tengo para impugnar una decisión de junta?';a='Los plazos son cortos — generalmente días o pocas semanas según el tipo de acción. Debes actuar inmediatamente cuando conoces la decisión cuestionable. Escríbenos: 0994859814.'},
    @{q='¿Puedo impugnar aunque no estuve en la junta?';a='Sí. Si no fuiste convocado correctamente o si la decisión viola tus derechos como socio, puedes impugnar aunque no hayas asistido. Escríbenos: 0994859814.'},
    @{q='¿Las actas de junta mal redactadas dan lugar a impugnación?';a='Pueden. Si el acta no refleja lo que ocurrió o si hay irregularidades en el proceso de la junta, eso puede ser fundamento de impugnación. Escríbenos: 0994859814.'},
    @{q='¿Qué diferencia hay entre impugnar y demandar nulidad de la junta?';a='La impugnación puede buscar la anulabilidad (vicio subsanable) o la nulidad absoluta (vicio que no puede subsanarse). La estrategia correcta depende del tipo de defecto. Escríbenos: 0994859814.'}
)

Add-Faqs 'liquidacion-companias-conflictos.html' @(
    @{q='¿La liquidación de la empresa afecta a los empleados?';a='Sí. La liquidación implica el pago de todas las obligaciones laborales. Los empleados tienen prioridad en el pago frente a los socios. Escríbenos: 0994859814.'},
    @{q='¿Si decido liquidar voluntariamente puedo hacerlo sin el acuerdo de todos los socios?';a='Depende de los estatutos. Generalmente se requiere una mayoría calificada para disolver voluntariamente. Si no hay acuerdo, puede demandarse la disolución judicial. Escríbenos: 0994859814.'},
    @{q='¿Cuánto tiempo tarda la liquidación de una empresa en Ecuador?';a='El proceso formal de liquidación puede tomar de 6 meses a varios años dependiendo de las deudas, activos y si hay conflictos entre los socios o acreedores. Escríbenos: 0994859814.'},
    @{q='¿Los socios responden personalmente por las deudas de la empresa en liquidación?';a='En general no, hasta el límite del capital aportado. Pero hay excepciones si hubo manejo fraudulento o si la empresa carecía de patrimonio suficiente. Escríbenos: 0994859814.'}
)

Add-Faqs 'mercaderia-retenida-senae-ecuador.html' @(
    @{q='¿Cuánto tiempo tiene el SENAE para resolver la retención de mi mercancía?';a='Depende del tipo de retención. En aforo rojo el proceso puede durar días. Si hay sospecha de fraude puede extenderse semanas o meses. Escríbenos: 0994859814.'},
    @{q='¿Puedo retirar la mercancía dando una garantía mientras se resuelve?';a='En algunos casos sí. Dependiendo de la causal de retención, el SENAE puede aceptar una garantía o caución para permitir el retiro provisional. Escríbenos: 0994859814.'},
    @{q='¿Si el SENAE retiene mi mercancía injustificadamente quién paga las sobreestadías?';a='Si el SENAE generó la retención por un error propio y lo reconoce, puede haber lugar a reclamar esos costos. Es un proceso que requiere documentación y asesoría. Escríbenos: 0994859814.'},
    @{q='¿Qué abogado necesito para una retención de mercancía por el SENAE?';a='Un abogado especializado en derecho aduanero. Juristam puede orientarte en casos de retenciones y multas del SENAE. Escríbenos: 0994859814.'}
)

Add-Faqs 'multas-senae-ecuador.html' @(
    @{q='¿Puedo pagar la multa del SENAE en cuotas?';a='Depende del monto y las políticas vigentes del SENAE. Hay mecanismos de facilidades de pago para algunos casos. Consulta directamente o con asesoría. Escríbenos: 0994859814.'},
    @{q='¿Si impugno la multa y pierdo, debo pagar intereses adicionales?';a='Sí. Los intereses continúan corriendo durante el proceso de impugnación. Si pierdes, pagas el capital más todos los intereses acumulados. Escríbenos: 0994859814.'},
    @{q='¿El SENAE puede embargarme bienes si no pago la multa?';a='Sí. El SENAE tiene facultad coactiva para cobrar multas impagadas. Puede embargar bienes si no pagas o no impugnas en los plazos correctos. Escríbenos: 0994859814.'},
    @{q='¿Las multas del SENAE tienen plazo de prescripción?';a='Sí. Las multas administrativas del SENAE tienen plazos de prescripción establecidos en la normativa tributaria y aduanera. Consulta con asesoría para verificar tu caso. Escríbenos: 0994859814.'}
)

Add-Faqs 'multas-supercias-ecuador.html' @(
    @{q='¿Por qué causas multa más frecuentemente la Supercias?';a='Por no presentar estados financieros a tiempo, no realizar juntas generales anuales, no actualizar información societaria y no cumplir con las obligaciones de reporte. Escríbenos: 0994859814.'},
    @{q='¿Las multas de la Supercias tienen intereses si no se pagan a tiempo?';a='Sí. Las multas no pagadas generan intereses y el incumplimiento puede escalar a procesos coactivos de cobro. Escríbenos: 0994859814.'},
    @{q='¿Si demuestro que el incumplimiento fue por fuerza mayor, me exoneran?';a='Puede ser una defensa válida. La Supercias puede considerar circunstancias excepcionales en el proceso de apelación de la multa. Escríbenos: 0994859814.'},
    @{q='¿Puedo negociar el valor de la multa con la Supercias?';a='El proceso es de impugnación formal, no de negociación directa. Puedes demostrar que la multa fue mal calculada o que hay circunstancias que la reducen. Escríbenos: 0994859814.'}
)

Add-Faqs 'objeto-social-empresa-ecuador.html' @(
    @{q='¿El objeto social puede ser muy amplio para cubrir todo?';a='Puede intentarse, pero el SENADI y la Supercias pueden observar objetos sociales demasiado amplios o que no sean coherentes entre sí. Escríbenos: 0994859814.'},
    @{q='¿Si quiero expandir mi negocio debo cambiar el objeto social?';a='Si la nueva actividad no está cubierta por el objeto actual, sí. Operar fuera del objeto social puede generar problemas regulatorios y de responsabilidad. Escríbenos: 0994859814.'},
    @{q='¿Un objeto social genérico es suficiente para cualquier actividad empresarial?';a='No siempre. Algunas actividades reguladas requieren menciones específicas en el objeto social. Sin eso la empresa no puede obtener permisos sectoriales. Escríbenos: 0994859814.'},
    @{q='¿Cambiar el objeto social es costoso?';a='Requiere reforma de estatutos: junta general, escritura pública e inscripción. Es más costoso que hacerlo bien desde el inicio. Escríbenos: 0994859814.'}
)

Add-Faqs 'planificacion-patrimonial-empresarial-ecuador.html' @(
    @{q='¿Cuándo debo empezar a planificar mi patrimonio empresarial?';a='Desde el momento en que empiezas a acumular activos. La planificación preventiva es mucho más efectiva que actuar cuando ya hay un problema. Escríbenos: 0994859814.'},
    @{q='¿La planificación patrimonial es legal o puede considerarse evasión?';a='La planificación patrimonial legal usa los instrumentos que la ley permite. No es evasión — es el uso inteligente de las herramientas disponibles. Escríbenos: 0994859814.'},
    @{q='¿El holding empresarial es una herramienta de planificación patrimonial?';a='Sí. Crear una empresa holding que posea las participaciones de otras puede separar el patrimonio y facilitar la planificación sucesoria y la protección de activos. Escríbenos: 0994859814.'},
    @{q='¿La planificación patrimonial también sirve para la sucesión familiar?';a='Sí. Es una de sus funciones principales. Organizar el patrimonio en vida facilita enormemente la transmisión ordenada a los herederos. Escríbenos: 0994859814.'}
)

Add-Faqs 'politicas-internas-empresa-ecuador.html' @(
    @{q='¿Qué política interna es la más importante para una empresa pequeña?';a='La de prevención de lavado de activos si está sujeta a esa obligación. Para las demás, las políticas de contratación y de manejo de información confidencial son prioritarias. Escríbenos: 0994859814.'},
    @{q='¿Las políticas internas deben estar firmadas por los empleados?';a='Sí. Para que sean exigibles es importante que los empleados las conozcan y las acepten. El acuse de recibo firmado es la mejor evidencia de eso. Escríbenos: 0994859814.'},
    @{q='¿Las políticas internas pueden reemplazar a un contrato laboral?';a='No. Las políticas internas complementan al contrato laboral pero no lo reemplazan. El contrato es el documento fundamental de la relación laboral. Escríbenos: 0994859814.'},
    @{q='¿Con qué frecuencia deben actualizarse las políticas internas?';a='Cuando cambia la normativa aplicable o cuando la experiencia de la empresa muestra que hay vacíos o situaciones no cubiertas. Al menos una revisión anual es recomendable. Escríbenos: 0994859814.'}
)

Add-Faqs 'posesion-notoria-apellidos-ecuador.html' @(
    @{q='¿Cuántos años de uso del apellido necesito para la posesión notoria?';a='La ley habla de un tiempo suficiente que demuestre identificación real con ese apellido. En la práctica el Registro Civil exige 10 años de uso documentado. Escríbenos: 0994859814.'},
    @{q='¿Si no tengo 10 años de uso documentado hay otra opción?';a='Sí. La vía judicial no requiere los 10 años. Se basa directamente en el derecho constitucional a la identidad. Es el camino alternativo cuando no se cumple ese requisito. Escríbenos: 0994859814.'},
    @{q='¿Los documentos escolares sirven para probar la posesión notoria de apellidos?';a='Sí. Los registros escolares, universitarios, médicos y cualquier documento oficial donde hayas usado ese apellido contribuyen a probar la posesión notoria. Escríbenos: 0994859814.'},
    @{q='¿La posesión notoria de apellidos aplica también al cambio de nombre?';a='Los apellidos y el nombre tienen regímenes distintos. La posesión notoria aplica específicamente a los apellidos según la LOGIDAC. Escríbenos: 0994859814.'}
)

Add-Faqs 'prevencion-lavado-activos-empresas-ecuador.html' @(
    @{q='¿Cómo sé si mi empresa está sujeta a las obligaciones de prevención de lavado?';a='La Unidad de Análisis Financiero (UAF) emite la lista de sujetos obligados. También depende del sector y el monto de transacciones. Consulta para verificar tu situación. Escríbenos: 0994859814.'},
    @{q='¿Qué pasa si mi empresa no cumple con las obligaciones de prevención?';a='Multas de la UAF, responsabilidad del representante legal y en casos graves consecuencias penales. El incumplimiento tiene consecuencias severas. Escríbenos: 0994859814.'},
    @{q='¿El oficial de cumplimiento debe ser un abogado?';a='No necesariamente, pero debe tener capacitación específica en prevención de lavado de activos. En empresas medianas puede ser el mismo representante legal. Escríbenos: 0994859814.'},
    @{q='¿Qué es un reporte de operación inusual y cuándo debo presentarlo?';a='Es el reporte que se presenta a la UAF cuando una transacción no tiene justificación económica aparente. Los plazos y condiciones exactas dependen de la normativa de tu sector. Escríbenos: 0994859814.'}
)

Add-Faqs 'representante-legal-responsabilidad-ecuador.html' @(
    @{q='¿Puedo negarme a ser representante legal para evitar responsabilidades?';a='Sí. Nadie está obligado a aceptar ese cargo. Pero si ya lo aceptaste, renunciar requiere un proceso formal y no te exime de responsabilidades por actos anteriores. Escríbenos: 0994859814.'},
    @{q='¿El representante legal responde aunque no haya actuado personalmente en el fraude?';a='Si tenía el deber de supervisar y no lo hizo, puede tener responsabilidad por omisión. El desconocimiento no siempre es defensa suficiente. Escríbenos: 0994859814.'},
    @{q='¿Cómo puedo protegerme como representante legal?';a='Con un programa de compliance sólido, documentar todas las decisiones importantes, no actuar fuera del objeto social y consultar a un abogado antes de decisiones de alto riesgo. Escríbenos: 0994859814.'},
    @{q='¿La empresa puede asumir la defensa legal del representante legal si hay un problema?';a='Depende de los estatutos y del tipo de problema. Si actuó dentro de sus facultades y de buena fe, la empresa generalmente asume la defensa. Escríbenos: 0994859814.'}
)

Add-Faqs 'responsabilidad-socios-compania-ecuador.html' @(
    @{q='¿La responsabilidad limitada de los socios es absoluta en Ecuador?';a='No. Hay situaciones donde la responsabilidad puede extenderse al patrimonio personal: confusión de patrimonios, fraude o uso de la empresa para actividades ilegales. Escríbenos: 0994859814.'},
    @{q='¿Qué es el levantamiento del velo societario en Ecuador?';a='Es cuando el juez desconoce la separación entre la empresa y sus socios y hace que los socios respondan personalmente por las deudas de la empresa. Aplica en casos de fraude o abuso. Escríbenos: 0994859814.'},
    @{q='¿Si soy socio pero no gestor, respondo igual por las deudas?';a='En principio solo hasta tu aportación. Pero si participaste en actos fraudulentos aunque no seas el representante, puede extenderse tu responsabilidad. Escríbenos: 0994859814.'},
    @{q='¿Cómo evito que se aplique el levantamiento del velo societario?';a='Manteniendo separados los patrimonios personal y empresarial, documentando todas las transacciones entre el socio y la empresa y operando siempre dentro del objeto social. Escríbenos: 0994859814.'}
)

Add-Faqs 'senae-retencion-mercaderia.html' @(
    @{q='¿La retención de mercancía por el SENAE es lo mismo que el decomiso?';a='No. La retención es temporal mientras se verifica la legalidad de la importación. El decomiso es definitivo cuando se confirma una infracción grave. Escríbenos: 0994859814.'},
    @{q='¿Cuánto tiempo puede el SENAE retener la mercancía sin resolver?';a='El SENAE tiene plazos establecidos para resolver. Si los supera sin justificación, puedes exigir la resolución mediante recursos administrativos. Escríbenos: 0994859814.'},
    @{q='¿Si el SENAE retiene mi mercancía puedo seguir importando otros productos?';a='Sí. Una retención sobre un embarque específico no bloquea automáticamente todas tus operaciones. Pero puede afectar tu perfil de riesgo ante el SENAE. Escríbenos: 0994859814.'},
    @{q='¿Qué pasa si la mercancía retenida se deteriora mientras espera la resolución?';a='Puedes reclamar los daños si la retención fue injustificada o si el SENAE no cuidó adecuadamente la mercancía durante el período de custodia. Escríbenos: 0994859814.'}
)

Add-Faqs 'separar-patrimonio-personal-empresa.html' @(
    @{q='¿Qué errores cometen los empresarios que mezclan patrimonios?';a='Pagar gastos personales con la tarjeta de la empresa, depositar ingresos del negocio en cuentas personales y no documentar préstamos entre el socio y la empresa. Escríbenos: 0994859814.'},
    @{q='¿Si mi empresa quiebra puede afectar mi casa o mis ahorros personales?';a='Si los patrimonios están correctamente separados, no. Pero si los mezclaste, el acreedor puede argumentar que el patrimonio personal también responde. Escríbenos: 0994859814.'},
    @{q='¿Una cuenta bancaria separada es suficiente para separar patrimonios?';a='Es el primer paso, pero no suficiente. Necesitas también contratos formales para toda transacción entre tú y la empresa, y registros contables impecables. Escríbenos: 0994859814.'},
    @{q='¿La separación patrimonial tiene ventajas fiscales?';a='Puede optimizar la carga fiscal si está bien estructurada. Pero el objetivo principal es la protección patrimonial, no la evasión fiscal. Escríbenos: 0994859814.'}
)

Add-Faqs 'subvaloracion-aduanera-ecuador.html' @(
    @{q='¿Qué pasa si el precio que declaré fue el real pero el SENAE lo considera bajo?';a='El SENAE aplica métodos de valoración aduanera específicos. Si el precio declarado no coincide con sus referencias, debes probar con documentación que el tuyo es el real. Escríbenos: 0994859814.'},
    @{q='¿Puedo importar mercancía de un familiar en el exterior a precio preferencial?';a='Las transacciones entre partes vinculadas tienen reglas especiales de valoración. El SENAE puede cuestionar precios preferenciales entre empresas o personas relacionadas. Escríbenos: 0994859814.'},
    @{q='¿La subvaloración genera solo multa o también puede ser delito penal?';a='En casos graves de subvaloración sistemática puede configurarse defraudación aduanera, que es un delito penal. Las consecuencias van más allá de la multa administrativa. Escríbenos: 0994859814.'},
    @{q='¿Cómo me defiendo si el SENAE dice que subvaloré pero yo creo que no?';a='Con la documentación original de la transacción: factura del proveedor, contrato de compraventa, registros bancarios del pago y precio de mercado comparable. Escríbenos: 0994859814.'}
)

Add-Faqs 'testamento-casado-hijos-diferentes-parejas-ecuador.html' @(
    @{q='¿Pueden los hijos de diferentes parejas impugnar el testamento entre sí?';a='Sí. Cada hijo tiene derecho a reclamar su legítima. Si el testamento la viola, cualquier heredero forzoso puede impugnarlo judicialmente. Escríbenos: 0994859814.'},
    @{q='¿El cónyuge actual compite con los hijos de parejas anteriores?';a='Tanto el cónyuge como todos los hijos son herederos forzosos con porciones específicas. El testamento debe respetar las legítimas de todos. Escríbenos: 0994859814.'},
    @{q='¿Puedo excluir a los hijos de mi primera pareja en favor de los de la segunda?';a='No puedes excluirlos si tienen derecho a legítima. Solo en las 5 causales de desheredación reconocidas puedes excluir a un hijo. Escríbenos: 0994859814.'},
    @{q='¿El testamento puede establecer turnos de uso de bienes entre hijos de distintas parejas?';a='Sí. El testamento puede establecer condiciones y plazos de uso de bienes como usufructo temporal para una pareja y plena propiedad para los hijos. Escríbenos: 0994859814.'}
)

Add-Faqs 'tipos-companias-ecuador.html' @(
    @{q='¿Cuál es la diferencia principal entre una SAS y una Cía. Ltda.?';a='La SAS tiene más flexibilidad en su estructura y puede constituirse con un solo socio. La Cía. Ltda. requiere mínimo 2 socios y tiene estructura más rígida. Escríbenos: 0994859814.'},
    @{q='¿La Sociedad Anónima es solo para grandes empresas?';a='No. La S.A. puede constituirse con capital relativamente bajo. Es más común cuando hay múltiples accionistas o cuando se busca mayor facilidad para transferir participaciones. Escríbenos: 0994859814.'},
    @{q='¿Si elijo mal el tipo de sociedad puedo cambiar después?';a='Sí, pero la transformación societaria tiene costos y trámites. Es mejor elegir bien desde el inicio con asesoría adecuada. Escríbenos: 0994859814.'},
    @{q='¿Cuál tipo de sociedad recomendarías para una empresa de servicios profesionales?';a='Depende de varios factores. En muchos casos la SAS es la más flexible. Pero la elección correcta requiere analizar número de socios, capital, sector y proyecciones de crecimiento. Escríbenos: 0994859814.'}
)

Write-Host "`n=== DONE === Updated=$($updated) | Skipped=$($skipped) | NotFound=$($notFound)"
