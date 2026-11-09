# API de productos

API REST generada con Spring Initializr, Spring Boot y Spring Web. Los productos se guardan en memoria: la lista empieza vacia y se pierde al reiniciar la aplicacion. No se necesita una base de datos.

## Requisitos y ejecucion

Se necesita un **JDK 25 o superior**. El proyecto incluye Maven Wrapper, por lo que no es necesario instalar Maven.

En PowerShell, desde la carpeta del proyecto:

```powershell
.\mvnw.cmd spring-boot:run
```

Si hay varias versiones de Java, configure `JAVA_HOME` con la ruta de un JDK compatible antes de ejecutar el comando. Por ejemplo:

```powershell
$env:JAVA_HOME = 'C:\ruta\al\jdk'
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
.\mvnw.cmd spring-boot:run
```

El primer inicio necesita acceso a Internet para descargar Maven y las dependencias.

## Endpoints

| Metodo | Ruta | Resultado |
| --- | --- | --- |
| GET | `/api/productos` | 200 con todos los productos |
| GET | `/api/productos/{id}` | 200 con el producto o 404 si no existe |
| POST | `/api/productos` | 201 con el producto creado y cabecera `Location`; 400 si los datos son invalidos |
| DELETE | `/api/productos/{id}` | 204 sin cuerpo o 404 si no existe |

Ejemplo para registrar un producto:

```json
{
  "nombre": "Cuaderno",
  "precio": 12.50,
  "stock": 10
}
```

El servidor genera el `id`; si se incluye en el cuerpo de la solicitud, se ignora. El nombre es obligatorio, el precio debe ser mayor que cero y el stock debe ser un entero mayor o igual a cero. Las respuestas de error incluyen, por ejemplo:

```json
{
  "mensaje": "El precio debe ser mayor que cero.",
  "estado": 400
}
```

## Pruebas

Con la aplicacion en ejecucion, visite `http://localhost:8080/api/productos` en el navegador para consultar la lista y `http://localhost:8080/api/productos/1` para consultar un producto con ese identificador, despues de crearlo.

Para ejecutar las pruebas HTTP en otra ventana de PowerShell:

```powershell
.\pruebas-http.ps1
```

El guion crea un producto de prueba, comprueba los resultados y lo elimina. Prueba la consulta de la lista, la consulta de productos existentes e inexistentes, el registro valido, el precio invalido, el stock negativo y la eliminacion existente e inexistente. Tambien comprueba solicitudes mal formadas. Puede utilizar un puerto diferente mediante `.\pruebas-http.ps1 -BaseUrl 'http://localhost:8081'`.

Ejemplos manuales:

```powershell
Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/api/productos' -ContentType 'application/json' -Body '{"nombre":"Cuaderno","precio":12.5,"stock":10}'
Invoke-RestMethod -Method Get -Uri 'http://localhost:8080/api/productos/1'
Invoke-RestMethod -Method Delete -Uri 'http://localhost:8080/api/productos/1'
```
