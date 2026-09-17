/*
 * Anteprima del codice export nelle modali articolo (placca, accessorio, segnaletica).
 * Il codice (articolo + variante a 10 caratteri) viene composto dal server con la
 * stessa logica dell'esportazione (Quotation.composeExportCode), così l'utente vede
 * mentre compila gli attributi se quelli "da esportare" entrano nei 10 caratteri.
 *
 * File a sé perché usato dalle modali placca/accessorio/segnaletica, condivise sia
 * dalla pagina di dettaglio preventivo (app-quotation-detail.js) sia dalla pagina
 * posizionamento piante (app-quotation-plant-positions.js): va incluso in entrambe,
 * vedi jsFiles in QuotationController.cfc.
 */
AP.namespace("quotation");

AP.quotation.exportCode = (function () {
	var pub = {};
	var timers = {};

	var esc = function (str) {
		return $("<div>").text(str == null ? "" : String(str)).html();
	};

	// Chiede l'anteprima (debounce per chiave: una richiesta per modale ogni 250 ms).
	// payload: { productId, productItemIds, signage, signageConfigItemId }
	pub.preview = function (key, payload, done) {
		clearTimeout(timers[key]);
		timers[key] = setTimeout(function () {
			NM.util.ajax({
				method: "POST",
				url: "/manager/ajax/quotation-items/export-code-preview",
				data: JSON.stringify(payload),
				callback: {
					done: function (xhr) {
						done(xhr && xhr.data ? xhr.data : null);
					}
				}
			});
		}, 250);
	};

	// HTML della riga "Codice export": codice live (calcolato ora) ed eventuale codice
	// REALMENTE salvato in export_codes per la configurazione attuale dell'item
	// (savedExportCode, risolto server-side su quotation_items.hash - vedi
	// getSavedExportCode in QuotationItemAjaxController.cfc) affiancati sulla stessa
	// riga, quest'ultimo più grande ed evidenziato: è il codice storicamente esportato,
	// indipendente da quanto si sta digitando ora. L'eventuale errore (stesso messaggio
	// dell'export) va su una riga a sé sotto, senza andare a capo.
	// Il codice live resta nascosto finché non c'è un articleCode (nessun prodotto scelto
	// ancora): altrimenti una modale "nuovo articolo" mostrerebbe subito l'etichetta vuota
	// + l'errore "Prodotto non selezionato" prima ancora che l'utente inizi a compilare.
	pub.html = function (outcome, savedExportCode) {
		var liveHtml = "";
		var errorHtml = "";
		if (outcome && outcome.articleCode) {
			liveHtml += '<span class="text-muted">Codice export:</span> ';
			liveHtml += '<small class="text-muted">art.</small> <code title="Codice articolo: categoria + linea + modello + finitura">' + esc(outcome.articleCode) + "</code>";
			if (outcome.variantCode) {
				var variantTitle = outcome.success
					? "Codice variante: 10 caratteri, attributi da esportare + zeri di riempimento"
					: "Codice variante parziale: calcolo interrotto prima di aggiungere tutti gli attributi da esportare";
				liveHtml += ' <span class="text-muted">+</span> <small class="text-muted">var.</small> <code style="background-color:#eef2f7;border-radius:3px;padding:0 3px;" title="' + esc(variantTitle) + '">' + esc(outcome.variantCode) + "</code>";
			}
			if (!outcome.success && outcome.error) {
				errorHtml = '<div class="text-danger text-nowrap"><i class="fas fa-exclamation-triangle"></i> ' + esc(outcome.error) + "</div>";
			}
		}

		var savedHtml = "";
		if (savedExportCode) {
			savedHtml = '<span class="badge" style="background-color:#e6f4ea;color:#1e7e34;border:1px solid #b7dfc0;font-weight:normal;font-size:.8rem;padding:.2em .2em;" title="Codice effettivamente registrato nell\'ultima esportazione di questo articolo">'
				+ '<i class="fas fa-check-circle"></i> Esportato: <code style="background:none;color:inherit;padding:0;font-size:.8rem;">' + esc(savedExportCode) + "</code></span>";
		}

		if (!liveHtml && !savedHtml) {
			return "";
		}

		var html = '<div style="display:flex;align-items:center;gap:.75rem;flex-wrap:wrap;">';
		if (liveHtml) {
			html += "<span>" + liveHtml + "</span>";
		}
		html += savedHtml;
		html += "</div>";
		html += errorHtml;

		return html;
	};

	pub.render = function (container, outcome, savedExportCode) {
		$(container).html(pub.html(outcome, savedExportCode));
	};

	// Badge discreto accanto al nome dell'attributo "da esportare"
	pub.badge = function (code) {
		return $('<span class="badge rounded-pill bg-light text-secondary border ms-1 export-attr-badge" style="font-size: 9px; vertical-align: middle;"></span>')
			.attr("title", 'Attributo da esportare: il codice "' + code + '" entra nel codice variante (10 caratteri)')
			.html('<i class="fas fa-file-export"></i> ' + esc(code));
	};

	// Applica i badge agli attributi importanti dentro un albero attributi (modali Kendo):
	// ogni attributo ha un contenitore #attribute-container-<attributeId> con il label per primo.
	pub.markImportant = function (container, importantAttributes) {
		var $c = $(container);
		$c.find(".export-attr-badge").remove();
		(importantAttributes || []).forEach(function (attr) {
			var $label = $c.find("#attribute-container-" + attr.id + " > label").first();
			if ($label.length) {
				$label.append(pub.badge(attr.code));
			}
		});
	};

	return pub;
})();
