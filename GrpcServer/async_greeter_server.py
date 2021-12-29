# Copyright 2020 gRPC authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""The Python AsyncIO implementation of the GRPC helloworld.Greeter server."""

import asyncio
import logging
import os

import grpc

import exporter_pb2
import exporter_pb2_grpc

import psycopg2


class Exporter(exporter_pb2_grpc.ExporterServicer):
    async def Export(self, request: exporter_pb2.Row, context: grpc.aio.ServicerContext) -> exporter_pb2.Reply:
        print(f'{request.game_name.value}, {request.category_name.value}, {request.achievement_name.value}, {request.downloadable_content_name.value}')
        db_host = os.environ.get('POSTGRES_HOST')
        db_name = os.environ.get('POSTGRES_DB')
        db_user = os.environ.get('POSTGRES_USER')
        db_pass = os.environ.get('POSTGRES_PASSWORD')
        db_port = os.environ.get('POSTGRES_PORT')
        connection = psycopg2.connect(host=db_host, database=db_name, user=db_user, password=db_pass, port=db_port)
        cursor = connection.cursor()
        cursor.execute('call export(%s, %s, %s, %s)',
                       (
                           request.game_name.value,
                           request.achievement_name.value,
                           request.category_name.value,
                           request.downloadable_content_name.value
                       ))
        connection.commit()
        connection.close()
        return exporter_pb2.Reply(ok=True)


async def serve() -> None:
    # create server
    server = grpc.aio.server()

    # add services
    exporter_pb2_grpc.add_ExporterServicer_to_server(Exporter(), server)

    # add secure port
    listen_addr = '[::]:5001'
    server.add_insecure_port(listen_addr)
    logging.info("Starting server on %s", listen_addr)
    await server.start()
    await server.wait_for_termination()


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    asyncio.run(serve())