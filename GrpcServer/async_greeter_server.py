import asyncio
import logging
import os

import grpc
import exporter_pb2
import exporter_pb2_grpc

from google.cloud.sql.connector import connector


class Exporter(exporter_pb2_grpc.ExporterServicer):
    async def Export(self, request: exporter_pb2.Row, context: grpc.aio.ServicerContext) -> exporter_pb2.Reply:
        print(f'{request.game_name.value}, {request.category_name.value}, {request.achievement_name.value}, {request.downloadable_content_name.value}')
        instance_connection_string = os.environ.get('INSTANCE_CONNECTION_STRING')
        driver = os.environ.get('DRIVER')
        user = os.environ.get('USER')
        password = os.environ.get('PASSWORD')
        db = os.environ.get('DB_NAME')
        connection = connector.connect(
            instance_connection_string=instance_connection_string,
            driver=driver,
            user=user,
            password=password,
            db=db
        )
        cursor = connection.cursor()

        #
        # connection = psycopg2.connect(host=db_host, database=db_name, user=db_user, password=db_pass, port=db_port)
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
