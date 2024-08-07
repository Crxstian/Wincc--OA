// Author..........: Laboratorio Telecomando
// Date............: December 2023
// Version.........: 1.0 for WinCC OA v3.13
// Modify..........: 
// Description.....: Energy reception to display energy consumption            

main(){
    // DP Valor Inicial
    string dpEnergia = "System1:R08_132_Recepcion_L579_E.Values.MeasureValue:_original.._value";
    // DP donde se envía el resultado
    string dpResultante = "System1:R08_132_579_EnAct_15min.Values.MeasureValue:_original.._value";
    // DP Estampa de Tiempo
    string estampa = "System1:R08_132_579_EnAct_15min.Values.MeasureValue:_original.._stime";
    
    int temporizacion = 60;  // intervalo de tiempo en Minutos entre mediciones de energia
    float valorInicial, valorActual, resultado;
    time horaActual = getCurrentTime();
    time horaEstampa;
    
    file archivo;
    string path = "ruta/del/archivo/";  
    string extension = ".txt";
    string archivoActual = "archivo_resultados.txt";
    string timeToTxt, nuevoArchivo;

    Debug(horaActual);
    Debug("Hello world"); 
while (1){
    horaActual = getCurrentTime();
    //if (minute(horaActual) % (temporizacion/60) == 0) 
    if (minute(horaActual) % temporizacion == 0 && second(horaActual) <= 1) {
        archivo = fopen(archivoActual, "a");  
        // Obtener el Valor Inicial
        dpGet(dpEnergia, valorInicial);
        Debug("----------Esperando Delay 15 Minutos----------");
        // Esperar 15 minutos para tomar el nuevo valor 
        delay(temporizacion*60);

        // Obtener el nuevo Valor después de 15 minutos 
        dpGet(dpEnergia, valorActual);
        
        dpGet(estampa, horaEstampa);
        horaEstampa = makeTime(year(horaEstampa),month(horaEstampa),day(horaEstampa),hour(horaEstampa),minute(horaEstampa),0,0);
        Debug("-----Variable ESTAMPA:  ----->");
        Debug(horaEstampa);
        
        // Realizar la Resta
        resultado = valorActual - valorInicial;

        // Establecer el resultado en otro datapoint
        dpSet(dpResultante, resultado);

        // Determinar el nombre del archivo según la fecha actual
        nuevoArchivo = path + year(horaEstampa) + "_" + month(horaEstampa) + extension;

        if (nuevoArchivo != archivoActual) {
            // Cambió el mes, cerrar el archivo actual y abrir uno nuevo
            if (archivo != -1) {
                fclose(archivo);
                Debug("Cerró el archivo actual");
            }

            archivoActual = nuevoArchivo;
            archivo = fopen(archivoActual, "a");

            if (archivo != -1) {
                Debug("Abrió el archivo nuevo: " + archivoActual);
                timeToTxt = year(horaActual)+"."+month(horaActual)+"."+day(horaActual)+" "+hour(horaActual)+":"+minute(horaActual)+":"+0+";"+0;
                // Escribir el resultado en una nueva línea del archivo
                fprintf(archivo, "%s;%f\n",timeToTxt, resultado);
                // Cerrar el archivo después de escribir
                fclose(archivo);
                Debug("Escribio correctamente en archivo");
            } else {
                Debug("Error al abrir el archivo nuevo: " + archivoActual);
            }
        }
        
        if (archivo != -1) {
          //2023.12.27 10:05:49.549;0.013312
            timeToTxt = year(horaActual)+"."+month(horaActual)+"."+day(horaActual)+" "+hour(horaActual)+":"+minute(horaActual)+":"+0+";"+0;
            // Escribir el resultado en una nueva línea del archivo
            fprintf(archivo, "%s;%f\n",timeToTxt, resultado);
            // Cerrar el archivo después de escribir
            fclose(archivo);
            Debug("Escribio correctamente en archivo");
        } else {
            // Manejo de error si no se puede abrir el archivo
            Debug("Error al abrir el archivo para escribir.");
        }
    }}
}
