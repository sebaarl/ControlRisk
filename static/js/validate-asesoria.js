const formularioAsesoria = document.getElementById("form-asesoria");
const inputsAsesoria = document.querySelectorAll("#form-asesoria input");

function sumarDias(fecha, dias) {
    fecha.setDate(fecha.getDate() + dias);
    return fecha;
}

const validarFormulario = (e) => {
    switch (e.target.name) {
        case "fecha":
            var fecha = new Date(e.target.value);
            var f1 = new Date(sumarDias(fecha, 1)).toDateString();
            var f2 = Date.now();
            var f3 = new Date(f2).toDateString();

            var f4 = new Date(f1);
            var f5 = new Date(f3);
            var f6 = new Date(sumarDias(f5, 14))

            if (f4 <= f6) {
                document
                    .querySelector("#input-field-fecha .alert-input")
                    .classList.add("alert-input-active");
                document.getElementById("alert-input").innerHTML = "La fecha ingresada debe ser mayor a " + f6.toDateString();
                const btn = document.getElementById("btn");
                btn.disabled = true;
            } else {
                document
                    .querySelector("#input-field-fecha .alert-input")
                    .classList.remove("alert-input-active");

                const btn = document.getElementById("btn");
                btn.disabled = false;
            }
            break;
    };
    switch (e.target.name) {
        case "hora":
            if (new Date(e.target.value).toDateString() >= new Date (new Date().toDateString() + ' ' + '10:00') && new Date(e.target.value).toDateString() <= new new Date (new Date().toDateString() + ' ' + '18:00')) {
                document
                    .querySelector("#input-field-hora .alert-input")
                    .classList.add("alert-input-active");
                btn.disabled = true;
            } else {
                document
                    .querySelector("#input-field-hora .alert-input")
                    .classList.remove("alert-input-active");

                const btn = document.getElementById("btn");
                btn.disabled = false;
            }
            break;
    };
}

inputsAsesoria.forEach((input) => {
    input.addEventListener("keyup", validarFormulario);
    input.addEventListener("blur", validarFormulario);
});