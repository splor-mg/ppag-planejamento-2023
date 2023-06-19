from frictionless import Package, Resource, Dialect
import requests
from bs4 import BeautifulSoup
import logging
import typer
import shutil
from datetime import datetime
import re
import pytz

logger = logging.getLogger(__name__)

def extract(resource_name, descriptor):
    package = Package(descriptor)
    resource = package.get_resource(resource_name)

    # 22:04:01 - Geração de Arquivos Texto, aguarde esse processamento pode ser um pouco demorado!
    # ATENÇÃO: Ao abrir o arquivo no Excel use o caracter | como separador de campos
    # 22:05:14 - Arquivo : programas_planejamento.txt gerado com sucesso!!!
    # Tempo de Processamento 00:01:13
    logger.info(f"Geração de arquivo texto para {resource.sources[0]['name']}. Aguarde esse processamento pode ser um pouco demorado!")
    res = requests.get(resource.sources[0]['api_url']) # Resource is stripping url property
    res.raise_for_status()
    if 'gerado com sucesso!' not in res.text:
        raise Exception
    
    soup = BeautifulSoup(res.text, 'html.parser')
    
    for p in soup.find_all('p'):
        if 'gerado com sucesso!' in p.get_text():
            logger.info(p.get_text().strip())
            today = datetime.now(pytz.timezone('America/Sao_Paulo'))
            time_pattern = re.compile(r'\b(\d{2}:\d{2}:\d{2})\b')
            time_match = time_pattern.search(p.get_text().strip())

            if time_match is not None:
                time_str = time_match.group(1)
                parsed_time = datetime.strptime(time_str, "%H:%M:%S")
                parsed_datetime = datetime(today.year, today.month, today.day,
                                    parsed_time.hour, parsed_time.minute, parsed_time.second, tzinfo=pytz.timezone('America/Sao_Paulo'))

                logger.info(parsed_datetime)
            else:
                logger.warning('Horário de finalização do processamento não encontrado')

    for p in soup.find_all('p'):
        if 'Tempo de Processamento' in p.get_text():
            logger.info(p.get_text().strip())

    resource_source = Resource(path=resource.sources[0]['download_url'],
                               format=resource.sources[0]['format'],
                               encoding=resource.sources[0]['encoding'],
                               dialect=Dialect(resource.sources[0]['dialect']),
                               schema=resource.sources[0]['schema'])

    with resource_source as source:
        with open(resource.sources[0]['path'], 'wb') as fs:
            shutil.copyfileobj(source.byte_stream, fs)

def main(resource_name: str, descriptor: str = 'datapackage.yaml'):
    extract(resource_name, descriptor)

if __name__ == '__main__':
    LOG_FORMAT = '%(asctime)s %(levelname)-5.5s [%(name)s] %(message)s'
    LOG_DATE_FORMAT = '%Y-%m-%dT%H:%M:%S%z'
    logging.basicConfig(format=LOG_FORMAT, datefmt=LOG_DATE_FORMAT, level=logging.INFO)
    typer.run(main)