from .forms import CreateClienteForm, CreateEmpleadoForm, CreateContratoForm, CreateAccidenteForm, CreateAsesoriaEspecial


def BaseForms(request):
    cliente_form = CreateClienteForm()
    empleado_form = CreateEmpleadoForm()
    contract_form = CreateContratoForm()
    accident_form = CreateAccidenteForm()
    especial_form = CreateAsesoriaEspecial()

    return {
        'clienteForm': cliente_form,
        'empForm': empleado_form,
        'contractForm': contract_form,
        'accidentForm': accident_form,
        'especialForm': especial_form
    }