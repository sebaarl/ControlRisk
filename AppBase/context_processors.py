from .forms import CreateClienteForm, CreateEmpleadoForm, CreateContratoForm, CreateAccidenteForm, CreateAsesoriaEspecial, EstadoAsesoria, EstadoVisita


def BaseForms(request):
    cliente_form = CreateClienteForm()
    empleado_form = CreateEmpleadoForm()
    contract_form = CreateContratoForm()
    accident_form = CreateAccidenteForm()
    especial_form = CreateAsesoriaEspecial()
    asesoria_form = EstadoAsesoria()
    visita_form = EstadoVisita()

    return {
        'clienteForm': cliente_form,
        'empForm': empleado_form,
        'contractForm': contract_form,
        'accidentForm': accident_form,
        'especialForm': especial_form,
        'asesoriaForm': asesoria_form,
        'visitaForm': visita_form,
    }