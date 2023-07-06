from frictionless import Package
import requests
import logging
import shutil
import html2text
from rich import print as rprint
from rich.panel import Panel
from rich.text import Text

logger = logging.getLogger(__name__)

def extract_resource(resource_name: str, descriptor: str = 'datapackage.yaml'):
    package = Package(descriptor)
    resource = package.get_resource(resource_name)

    # 22:04:01 - Geração de Arquivos Texto, aguarde esse processamento pode ser um pouco demorado!
    # ATENÇÃO: Ao abrir o arquivo no Excel use o caracter | como separador de campos
    # 22:05:14 - Arquivo : programas_planejamento.txt gerado com sucesso!!!
    # Tempo de Processamento 00:01:13
    logger.info(f"Extracting resource {resource_name}")
    res = requests.get(resource.custom['api_url']) # Resource is stripping url property
    res.raise_for_status()
    h = html2text.HTML2Text()
    rprint(Panel(Text(h.handle(res.text), style="green")))
    if 'gerado com sucesso!' not in res.text:
        logger.error('Erro na geração do arquivo texto')
        raise Exception
    
    res = requests.get(resource.custom['download_url'], stream=True)
    res.raise_for_status()
    res.raw.decode_content = True
    
    with open(resource.path, 'wb') as file:
        shutil.copyfileobj(res.raw, file)
