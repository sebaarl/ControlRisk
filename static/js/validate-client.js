const formularioClient = document.getElementById("form-client");
const inputsClient = document.querySelectorAll("#form-client input");

const expresiones = {
    nombre: /^[a-zA-ZÀ-ÿ\s]{1,40}$/,
    rut: /^\d{1,2}\.\d{3}\.\d{3}[-][0-9kK]{1}$/,
    telefono: /^(\+?56)?(\s?)(0?2)(\s?)[0-9]\d{7}$/,
};

const validarFormulario = (e) => {
    switch (e.target.name) {
        case "telefono":
            if (expresiones.telefono.test(e.target.value)) {
                document
                    .querySelector("#input-field-tel .alert-input")
                    .classList.remove("alert-input-active");

                const btn = document.getElementById("btn");
                btn.disabled = false;
            } else {
                document
                    .querySelector("#input-field-tel .alert-input")
                    .classList.add("alert-input-active");

                const btn = document.getElementById("btn");
                btn.disabled = true;
            }
            break;
        case "rut":
            if (expresiones.rut.test(e.target.value)) {
                document
                    .querySelector("#input-field-rut .alert-input")
                    .classList.remove("alert-input-active");

                const btn = document.getElementById("btn");
                btn.disabled = false;
            } else {
                document
                    .querySelector("#input-field-rut .alert-input")
                    .classList.add("alert-input-active");

                const btn = document.getElementById("btn");
                btn.disabled = true;
            }
            break;
        case "rutrepre":
            if (expresiones.rut.test(e.target.value)) {
                document
                    .querySelector("#input-field-reprerut .alert-input")
                    .classList.remove("alert-input-active");

                const btn = document.getElementById("btn");
                btn.disabled = false;
            } else {
                document
                    .querySelector("#input-field-reprerut .alert-input")
                    .classList.add("alert-input-active");

                const btn = document.getElementById("btn");
                btn.disabled = true;
            }
            break;
        case "representante":
            if (expresiones.nombre.test(e.target.value)) {
                document
                    .querySelector("#input-field-repre .alert-input")
                    .classList.remove("alert-input-active");

                const btn = document.getElementById("btn");
                btn.disabled = false;
            } else {
                document
                    .querySelector("#input-field-repre .alert-input")
                    .classList.add("alert-input-active");

                const btn = document.getElementById("btn");
                btn.disabled = true;
            }
            break;
    }
};

inputsClient.forEach((input) => {
    input.addEventListener("keyup", validarFormulario);
    input.addEventListener("blur", validarFormulario);
});