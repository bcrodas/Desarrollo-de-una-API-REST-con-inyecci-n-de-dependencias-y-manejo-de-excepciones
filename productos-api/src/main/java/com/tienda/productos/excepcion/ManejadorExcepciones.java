package com.tienda.productos.excepcion;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

@RestControllerAdvice
public class ManejadorExcepciones {

    public record ErrorRespuesta(String mensaje, int estado) {
    }

    @ExceptionHandler(ProductoNoEncontradoException.class)
    public ResponseEntity<ErrorRespuesta> manejarNoEncontrado(ProductoNoEncontradoException excepcion) {
        return respuesta(HttpStatus.NOT_FOUND, excepcion.getMessage());
    }

    @ExceptionHandler(ProductoInvalidoException.class)
    public ResponseEntity<ErrorRespuesta> manejarInvalido(ProductoInvalidoException excepcion) {
        return respuesta(HttpStatus.BAD_REQUEST, excepcion.getMessage());
    }

    @ExceptionHandler({HttpMessageNotReadableException.class, MethodArgumentTypeMismatchException.class})
    public ResponseEntity<ErrorRespuesta> manejarSolicitudIncorrecta(Exception excepcion) {
        return respuesta(HttpStatus.BAD_REQUEST, "La solicitud contiene datos invalidos o tiene un formato incorrecto.");
    }

    private ResponseEntity<ErrorRespuesta> respuesta(HttpStatus estado, String mensaje) {
        return ResponseEntity.status(estado).body(new ErrorRespuesta(mensaje, estado.value()));
    }
}
