def test_acoes_planejamento(package):
    report = package.get_resource('acoes_planejamento').validate()
    assert report.valid

def test_indicadores_planejamento(package):
    report = package.get_resource('indicadores_planejamento').validate()
    assert report.valid

def test_localizadores_todos_planejamento(package):
    report = package.get_resource('localizadores_todos_planejamento').validate()
    assert report.valid

def test_programas_planejamento(package):
    report = package.get_resource('programas_planejamento').validate()
    assert report.valid
