
package LAB01_ADA;

/**
 *
 * @author MATHIAS TORRES
 */

import java.util.Random;
import java.util.HashSet;
import java.util.Set;

public class SopaDeLetras {

    public static void main(String[] args) {
        int n = 6;  // Tamaño del tablero (6x6)
        char[][] tablero = new char[n][n];

        // Llenar el tablero
        llenarTablero(tablero);

        // Lista de palabras válidas de 4 letras
        String[] diccionario = {"PATO", "GATO", "LUNA", "CAMA", "SOLO", "PESO", "ALMA", "VINO", "RANA",
                                "SALA", "RIEL", "BOLA", "GIRA", "ALTA", "VIRA", "RICO", "BESO", "SAPO",
                                "PEGA", "RATA", "MARO", "PALO", "TACO", "PESE"};

        // Seleccionar 4 palabras aleatorias de 4 letras
        String[] palabras = seleccionarPalabrasAleatorias(diccionario, 4);

        // Insertar las palabras en el tablero (horizontal, vertical o diagonal)
        for (String palabra : palabras) {
            // Elegir aleatoriamente entre insertar horizontal, vertical o diagonal
            int direccion = new Random().nextInt(3); // 0=horizontal, 1=vertical, 2=diagonal
            if (direccion == 0) {
                insertarPalabraHorizontal(tablero, palabra, 1000);  // Limitar a 1000 intentos por palabra
            } else if (direccion == 1) {
                insertarPalabraVertical(tablero, palabra, 1000);
            } else {
                insertarPalabraDiagonal(tablero, palabra, 1000);
            }
        }

        // Llenar los espacios vacíos con letras aleatorias
        llenarEspacios(tablero);

        // Mostrar el tablero con las palabras insertadas
        System.out.println("\t\tSOPA DE LETRAS");
        System.out.println("-------------------------------------------------");
        mostrarTablero(tablero);

        // Buscar las palabras en el tablero (horizontal, vertical y diagonal)
        for (String palabra : palabras) {
            buscarPalabra(tablero, palabra);
        }
    }

    // Función para llenar el tablero con espacios vacíos
    static void llenarTablero(char[][] tablero) {
        for (int i = 0; i < tablero.length; i++) {
            for (int j = 0; j < tablero[i].length; j++) {
                tablero[i][j] = ' '; // Inicializamos con espacios vacíos
            }
        }
    }

    // Función para seleccionar palabras aleatorias del diccionario sin repeticiones
    static String[] seleccionarPalabrasAleatorias(String[] diccionario, int cantidad) {
        String[] palabras = new String[cantidad];
        Set<String> seleccionadas = new HashSet<>();  // Usamos un Set para evitar duplicados
        Random random = new Random();
        int i = 0;
        
        while (i < cantidad) {
            String palabra = diccionario[random.nextInt(diccionario.length)];
            if (!seleccionadas.contains(palabra)) {
                seleccionadas.add(palabra);
                palabras[i] = palabra;
                i++;
            }
        }
        return palabras;
    }

    // Función para insertar una palabra de forma horizontal en el tablero
    static void insertarPalabraHorizontal(char[][] tablero, String palabra, int maxIntentos) {
        Random random = new Random();
        boolean insertada = false;
        int intentos = 0;

        while (!insertada && intentos < maxIntentos) {
            int fila = random.nextInt(tablero.length);  // Selección aleatoria de fila
            int col = random.nextInt(tablero[0].length - palabra.length() + 1);

            // Verificar si se puede insertar la palabra en la posición seleccionada
            if (puedeInsertarHorizontal(tablero, palabra, fila, col)) {
                for (int i = 0; i < palabra.length(); i++) {
                    tablero[fila][col + i] = palabra.charAt(i);  // Insertar la palabra horizontalmente
                }
                insertada = true;
            }

            intentos++;
        }

        if (!insertada) {
            System.out.println("No se pudo insertar la palabra '" + palabra + "' despues de " + maxIntentos + " intentos.");
        }
    }

    // Función para insertar una palabra de forma vertical en el tablero
    static void insertarPalabraVertical(char[][] tablero, String palabra, int maxIntentos) {
        Random random = new Random();
        boolean insertada = false;
        int intentos = 0;

        while (!insertada && intentos < maxIntentos) {
            int fila = random.nextInt(tablero.length - palabra.length() + 1);
            int col = random.nextInt(tablero[0].length);  // Columna aleatoria

            // Verificar si se puede insertar la palabra en la posición seleccionada
            if (puedeInsertarVertical(tablero, palabra, fila, col)) {
                for (int i = 0; i < palabra.length(); i++) {
                    tablero[fila + i][col] = palabra.charAt(i);  // Insertar la palabra verticalmente
                }
                insertada = true;
            }

            intentos++;
        }

        if (!insertada) {
            System.out.println("No se pudo insertar la palabra '" + palabra + "' despues de " + maxIntentos + " intentos.");
        }
    }

    // Función para insertar una palabra de forma diagonal en el tablero
    static void insertarPalabraDiagonal(char[][] tablero, String palabra, int maxIntentos) {
        Random random = new Random();
        boolean insertada = false;
        int intentos = 0;

        while (!insertada && intentos < maxIntentos) {
            // Elegimos un punto inicial aleatorio
            int fila = random.nextInt(tablero.length - palabra.length() + 1);
            int col = random.nextInt(tablero[0].length - palabra.length() + 1);

            // Verificar si se puede insertar la palabra en la posición seleccionada
            if (puedeInsertarDiagonal(tablero, palabra, fila, col)) {
                for (int i = 0; i < palabra.length(); i++) {
                    tablero[fila + i][col + i] = palabra.charAt(i);  // Insertar la palabra diagonalmente
                }
                insertada = true;
            }

            intentos++;
        }

        if (!insertada) {
            System.out.println("No se pudo insertar la palabra '" + palabra + "' despues de " + maxIntentos + " intentos.");
        }
    }

    // Funciones para verificar si se puede insertar una palabra en el tablero
    static boolean puedeInsertarHorizontal(char[][] tablero, String palabra, int fila, int col) {
        for (int i = 0; i < palabra.length(); i++) {
            if (tablero[fila][col + i] != ' ' && tablero[fila][col + i] != palabra.charAt(i)) { // Si el espacio no está vacío y no coincide
                return false;
            }
        }
        return true;
    }

    // Función para verificar si se puede insertar una palabra verticalmente
    static boolean puedeInsertarVertical(char[][] tablero, String palabra, int fila, int col) {
        for (int i = 0; i < palabra.length(); i++) {
            if (tablero[fila + i][col] != ' ' && tablero[fila + i][col] != palabra.charAt(i)) { // Si el espacio no está vacío y no coincide
                return false;
            }
        }
        return true;
    }

    // Función para verificar si se puede insertar una palabra diagonalmente
    static boolean puedeInsertarDiagonal(char[][] tablero, String palabra, int fila, int col) {
        for (int i = 0; i < palabra.length(); i++) {
            if (tablero[fila + i][col + i] != ' ' && tablero[fila + i][col + i] != palabra.charAt(i)) { // Si el espacio no está vacío y no coincide
                return false;
            }
        }
        return true;
    }

    // Función para llenar los espacios vacíos con letras aleatorias
    static void llenarEspacios(char[][] tablero) {
        Random random = new Random();
        for (int i = 0; i < tablero.length; i++) {
            for (int j = 0; j < tablero[i].length; j++) {
                if (tablero[i][j] == ' ') {
                    tablero[i][j] = (char) ('A' + random.nextInt(26)); // Rellenar con letras aleatorias
                }
            }
        }
    }

    // Función para mostrar el tablero (centrado)
    static void mostrarTablero(char[][] tablero) {
        // Calcular el número de espacios necesarios para centrar el tablero
        int totalWidth = 34;  // Tamaño de la consola (ajustar según tu terminal)
        String tab = " ".repeat(totalWidth / 2);  // Agregar espacios para centrar

        for (int i = 0; i < tablero.length; i++) {
            System.out.print(tab);  // Imprimir los espacios antes de la línea
            for (int j = 0; j < tablero[i].length; j++) {
                System.out.print(tablero[i][j] + " ");
            }
            System.out.println();
        }
        System.out.println("-------------------------------------------------");
    }

    // Función para buscar una palabra en el tablero
    static void buscarPalabra(char[][] tablero, String palabra) {
        boolean encontrada = false;

        // Buscar horizontalmente
        for (int i = 0; i < tablero.length; i++) {
            for (int j = 0; j < tablero[i].length; j++) {
                if (buscarHorizontal(tablero, palabra, i, j)) {
                    System.out.println("La palabra '" + palabra + "' fue encontrada.");
                    System.out.println("Encontrada horizontalmente desde (" + (i+1) + ", " + (j+1) + ") hasta (" + (i+1) + ", " + (j + palabra.length()) + ")\n");
                    encontrada = true;
                    break;
                }
            }
            if (encontrada) break;
        }

        // Buscar verticalmente
        for (int i = 0; i < tablero.length; i++) {
            for (int j = 0; j < tablero[i].length; j++) {
                if (buscarVertical(tablero, palabra, i, j)) {
                    System.out.println("La palabra '" + palabra + "' fue encontrada.");
                    System.out.println("Encontrada verticalmente desde (" + (i+1) + ", " + (j+1) + ") hasta (" + (i + palabra.length()) + ", " + (j+1) + ")\n");
                    encontrada = true;
                    break;
                }
            }
            if (encontrada) break;
        }

        // Buscar diagonalmente
        for (int i = 0; i < tablero.length; i++) {
            for (int j = 0; j < tablero[i].length; j++) {
                if (buscarDiagonal(tablero, palabra, i, j)) {
                    System.out.println("La palabra '" + palabra + "' fue encontrada.");
                    System.out.println("Encontrada diagonalmente desde (" + (i+1) + ", " + (j+1) + ") hasta (" + (i + palabra.length()) + ", " + (j + palabra.length()) + ")\n");
                    encontrada = true;
                    break;
                }
            }
            if (encontrada) break;
        }

        if (!encontrada) {
            System.out.println("La palabra '" + palabra + "' no se encuentra en el tablero.");
        }
    }

    // Función para buscar horizontalmente
    static boolean buscarHorizontal(char[][] tablero, String palabra, int fila, int col) {
        if (col + palabra.length() > tablero[fila].length) return false;

        for (int i = 0; i < palabra.length(); i++) {
            if (tablero[fila][col + i] != palabra.charAt(i)) {
                return false;
            }
        }
        return true;
    }

    // Función para buscar verticalmente
    static boolean buscarVertical(char[][] tablero, String palabra, int fila, int col) {
        if (fila + palabra.length() > tablero.length) return false;

        for (int i = 0; i < palabra.length(); i++) {
            if (tablero[fila + i][col] != palabra.charAt(i)) {
                return false;
            }
        }
        return true;
    }

    // Función para buscar diagonalmente
    static boolean buscarDiagonal(char[][] tablero, String palabra, int fila, int col) {
        if (fila + palabra.length() > tablero.length || col + palabra.length() > tablero[0].length) return false;

        for (int i = 0; i < palabra.length(); i++) {
            if (tablero[fila + i][col + i] != palabra.charAt(i)) {
                return false;
            }
        }
        return true;
    }
}
