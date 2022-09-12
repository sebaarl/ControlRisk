from .forms import UserLoginForm


def login_form(request):
    login_form = UserLoginForm()

    return {
        'loginForm': login_form,
    }