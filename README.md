# PPAG 2020-2023, exercício 2023

## Pré-requisitos

Esse projeto utiliza o Python 3.10.6. Para criar um ambiente chamado `venv`, ativar o mesmo e instalar as dependências execute:

```python
python -m venv venv
. venv/Scripts/activate
pip install -r requirements.txt
```

## Uso

Os arquivos primários em formato `txt` ficam armazenados em `data/raw/`. É possível criar ou atualizar o [table schema](https://specs.frictionlessdata.io//table-schema/) dos mesmos executando

```bash
make infer
```
