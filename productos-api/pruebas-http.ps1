param(
    [string]$BaseUrl = 'http://localhost:8080'
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Net.Http
$client = [System.Net.Http.HttpClient]::new()
$base = $BaseUrl.TrimEnd('/') + '/api/productos'
$id = $null

function Solicitar([string]$metodo, [string]$ruta, [string]$cuerpo = $null) {
    $solicitud = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::new($metodo), $base + $ruta)
    if ($PSBoundParameters.ContainsKey('cuerpo')) {
        $solicitud.Content = [System.Net.Http.StringContent]::new($cuerpo, [System.Text.Encoding]::UTF8, 'application/json')
    }
    try {
        $respuesta = $client.SendAsync($solicitud).GetAwaiter().GetResult()
        try {
            $contenido = $respuesta.Content.ReadAsStringAsync().GetAwaiter().GetResult()
            return @{ Estado = [int]$respuesta.StatusCode; Cuerpo = $contenido; Location = $respuesta.Headers.Location }
        } finally {
            $respuesta.Dispose()
        }
    } finally {
        $solicitud.Dispose()
    }
}

function Comprobar([bool]$condicion, [string]$mensaje) {
    if (-not $condicion) {
        throw "FALLO: $mensaje"
    }
    Write-Host "OK: $mensaje"
}

function ComprobarError($respuesta, [int]$estado, [string]$mensaje) {
    Comprobar ($respuesta.Estado -eq $estado) "$mensaje devuelve HTTP $estado"
    $errorJson = $respuesta.Cuerpo | ConvertFrom-Json
    Comprobar (($errorJson.estado -eq $estado) -and -not [string]::IsNullOrWhiteSpace($errorJson.mensaje)) "$mensaje incluye estado y mensaje"
}

try {
    $lista = Solicitar 'GET' ''
    Comprobar ($lista.Estado -eq 200 -and $lista.Cuerpo.TrimStart().StartsWith('[')) 'Consulta de todos los productos'

    $creado = Solicitar 'POST' '' '{"nombre":"Producto de prueba","precio":12.50,"stock":0}'
    Comprobar ($creado.Estado -eq 201) 'Registro de producto valido'
    $producto = $creado.Cuerpo | ConvertFrom-Json
    $id = $producto.id
    Comprobar ($null -ne $id -and $producto.nombre -eq 'Producto de prueba' -and $producto.precio -eq 12.50 -and $producto.stock -eq 0) 'Datos del producto creado'
    Comprobar ($creado.Location.ToString() -eq "/api/productos/$id") 'Cabecera Location del producto creado'

    $lista = Solicitar 'GET' ''
    $productos = @($lista.Cuerpo | ConvertFrom-Json)
    Comprobar (@($productos | Where-Object { $_.id -eq $id }).Count -eq 1) 'La lista contiene el producto creado'
    $consulta = Solicitar 'GET' "/$id"
    $consultado = $consulta.Cuerpo | ConvertFrom-Json
    Comprobar ($consulta.Estado -eq 200 -and $consultado.id -eq $id) 'Consulta de producto existente'
    ComprobarError (Solicitar 'GET' '/-1') 404 'Consulta de producto inexistente'
    ComprobarError (Solicitar 'POST' '' '{"nombre":"Prueba","precio":0,"stock":1}') 400 'Precio cero'
    ComprobarError (Solicitar 'POST' '' '{"nombre":"Prueba","precio":-1,"stock":1}') 400 'Precio negativo'
    ComprobarError (Solicitar 'POST' '' '{"nombre":"Prueba","precio":1,"stock":-1}') 400 'Stock negativo'
    ComprobarError (Solicitar 'POST' '' '{"nombre":"Prueba","precio":1,"stock":-0.5}') 400 'Stock negativo fraccionario'
    ComprobarError (Solicitar 'POST' '' '{"nombre":"Prueba","precio":1,"stock":1.5}') 400 'Stock positivo fraccionario'
    ComprobarError (Solicitar 'POST' '' '{"nombre":"Prueba","precio":1}') 400 'Stock ausente'
    ComprobarError (Solicitar 'POST' '' '{"nombre":" ","precio":1,"stock":1}') 400 'Nombre vacio'
    ComprobarError (Solicitar 'POST' '' '{"nombre":"Prueba",') 400 'JSON mal formado'
    ComprobarError (Solicitar 'GET' '/abc') 400 'Identificador invalido'
    $eliminado = Solicitar 'DELETE' "/$id"
    Comprobar ($eliminado.Estado -eq 204 -and [string]::IsNullOrEmpty($eliminado.Cuerpo)) 'Eliminacion de producto existente'
    ComprobarError (Solicitar 'GET' "/$id") 404 'Consulta del producto eliminado'
    ComprobarError (Solicitar 'DELETE' "/$id") 404 'Eliminacion de producto inexistente'
    $id = $null
    Write-Host 'Todas las pruebas finalizaron correctamente.'
} finally {
    if ($null -ne $id) {
        $limpieza = Solicitar 'DELETE' "/$id"
        if ($limpieza.Estado -ne 204 -and $limpieza.Estado -ne 404) {
            Write-Warning "No se pudo eliminar el producto de prueba $id (HTTP $($limpieza.Estado))."
        }
    }
    $client.Dispose()
}
