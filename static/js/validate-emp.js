const formularioEmp = document.getElementById("form-emp");
const inputsEmp = document.querySelectorAll("#form-emp input");

const expresiones = {
    nombre: /^[a-zA-ZÀ-ÿ\s]{1,40}$/,
    rut: /^\d{1,2}\.\d{3}\.\d{3}[-][0-9kK]{1}$/,
    letra: /^[A-Za-z]+$/,
};

const validarFormulario = (e) => {
    switch (e.target.name) {
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
        case "nombre":
            if (expresiones.nombre.test(e.target.value)) {
                document
                    .querySelector("#input-field-nombre .alert-input")
                    .classList.remove("alert-input-active");

                const btn = document.getElementById("btn");
                btn.disabled = false;
            } else {
                document
                    .querySelector("#input-field-nombre .alert-input")
                    .classList.add("alert-input-active");

                const btn = document.getElementById("btn");
                btn.disabled = true;
            }
            break;
        case "apellido":
            if (expresiones.nombre.test(e.target.value)) {
                document
                    .querySelector("#input-field-apellido .alert-input")
                    .classList.remove("alert-input-active");

                const btn = document.getElementById("btn");
                btn.disabled = false;
            } else {
                document
                    .querySelector("#input-field-apellido .alert-input")
                    .classList.add("alert-input-active");

                const btn = document.getElementById("btn");
                btn.disabled = true;
            }
            break;
        case "cargo":
                if (expresiones.letra.test(e.target.value)) {
                    document
                        .querySelector("#input-field-cargo .alert-input")
                        .classList.remove("alert-input-active");
    
                    const btn = document.getElementById("btn");
                    btn.disabled = false;
                } else {
                    document
                        .querySelector("#input-field-cargo .alert-input")
                        .classList.add("alert-input-active");
    
                    const btn = document.getElementById("btn");
                    btn.disabled = true;
                }

                if (e.target.value == 'Profesional' || e.target.value == 'Administrador') {
                    document
                        .querySelector("#input-field-cargo .alert-input")
                        .classList.remove("alert-input-active");
    
                    const btn = document.getElementById("btn");
                    btn.disabled = false;
                } else {
                    document
                        .querySelector("#input-field-cargo .alert-input")
                        .classList.add("alert-input-active");
    
                    const btn = document.getElementById("btn");
                    btn.disabled = true;
                }
                break;
    }
};

inputsEmp.forEach((input) => {
    input.addEventListener("keyup", validarFormulario);
    input.addEventListener("blur", validarFormulario);
});
