AP.namespace("quotation");

AP.quotation.documents = (function () {
    var pub = {};
    var modalRoot = null;
    var quotationId = AP.page.quotation.id;
    var docs = [];

    function load() {
        NM.util.ajax({
            method: "GET",
            url: "/manager/ajax/quotations/" + quotationId + "/documents",
            callback: {
                done: function (xhr) {
                    docs = Array.isArray(xhr.data) ? xhr.data : [];
                    renderList();
                }
            }
        });
    }

    function renderList() {
        var tbody = $("#qt-documents-tbody");
        var empty = $("#qt-documents-empty");

        tbody.empty();

        if (!docs.length) {
            empty.show();
            return;
        }

        empty.hide();

        docs.forEach(function (doc, index) {
            var row = $("<tr>").attr("data-id", doc.id);

            var sortCell = $("<td>").addClass("pe-1");
            var upBtn = $('<button type="button" class="btn btn-sm btn-link p-0 me-1"><i class="fas fa-arrow-up"></i></button>');
            var downBtn = $('<button type="button" class="btn btn-sm btn-link p-0"><i class="fas fa-arrow-down"></i></button>');

            if (index === 0) upBtn.prop("disabled", true);
            if (index === docs.length - 1) downBtn.prop("disabled", true);

            upBtn.on("click", function () { move(index, -1); });
            downBtn.on("click", function () { move(index, 1); });

            sortCell.append(upBtn).append(downBtn);

            var nameCell = $("<td>").text(doc.originalName);

            var actionsCell = $("<td>").addClass("text-end text-nowrap");
            var downloadUrl = "/manager/ajax/quotations/" + quotationId + "/documents/" + doc.id + "/download";
            var downloadBtn = $('<a class="btn btn-sm btn-outline-primary me-1"><i class="fas fa-download"></i></a>').attr("href", downloadUrl).attr("download", doc.originalName);
            var deleteBtn = $('<button type="button" class="btn btn-sm btn-outline-danger"><i class="fas fa-trash"></i></button>');

            deleteBtn.on("click", function () { deleteDoc(doc.id); });

            actionsCell.append(downloadBtn).append(deleteBtn);

            row.append(sortCell).append(nameCell).append(actionsCell);
            tbody.append(row);
        });
    }

    function move(index, direction) {
        var newIndex = index + direction;
        if (newIndex < 0 || newIndex >= docs.length) return;

        var tmp = docs[index];
        docs[index] = docs[newIndex];
        docs[newIndex] = tmp;

        var items = docs.map(function (doc, i) {
            return { id: doc.id, sortOrder: i };
        });

        renderList();

        NM.util.ajax({
            method: "POST",
            url: "/manager/ajax/quotations/" + quotationId + "/documents/reorder",
            data: JSON.stringify({ items: items }),
            callback: {
                done: function () {}
            }
        });
    }

    function deleteDoc(id) {
        if (!confirm("Eliminare questo documento?")) return;

        NM.util.ajax({
            method: "POST",
            url: "/manager/ajax/quotations/" + quotationId + "/documents/delete",
            data: JSON.stringify({ id: id }),
            callback: {
                done: function () {
                    docs = docs.filter(function (d) { return d.id !== id; });
                    renderList();
                    AP.widget.notify("success", "Documento eliminato.");
                }
            }
        });
    }

    function upload() {
        var input = document.getElementById("qt-document-file-input");
        var file = input.files[0];
        if (!file) {
            AP.widget.notify("warning", "Seleziona un file da caricare.");
            return;
        }

        var status = $("#qt-document-upload-status");
        status.html("<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'> Caricamento in corso...");

        var reader = new FileReader();
        reader.readAsDataURL(file);
        reader.onload = function (evt) {
            NM.util.ajax({
                method: "POST",
                url: "/manager/ajax/quotations/" + quotationId + "/documents",
                data: JSON.stringify({
                    base64: evt.target.result,
                    originalName: file.name
                }),
                callback: {
                    done: function (xhr) {
                        status.html("");
                        if (xhr && xhr.data && xhr.data.id) {
                            input.value = "";
                            docs.push(xhr.data);
                            renderList();
                            AP.widget.notify("success", "Documento caricato.");
                        } else {
                            AP.widget.notify("error", "Errore durante il caricamento.");
                        }
                    }
                }
            });
        };
    }

    pub.open = function () {
        modalRoot = AP.quotation.fields.documentsModalRoot;
        load();
        NM.util.openModal(modalRoot);

        $("#qt-document-upload-btn").off("click").on("click", upload);
    };

    return pub;
}());
