
package LAB02_ADA;

import java.util.Random;
import java.util.Scanner;
/**
 *
 * @author MATHIAS TORRES
 */
public class SecuenciaMaxima {
    
    public static void main(String[] args){
        Scanner scanner = new Scanner(System.in);
        System.out.print("Ingrese el total de numeros de la secuencia :");
        int total = scanner.nextInt();
        
        ArrayEnteros(total);
    }
    
    public static void ArrayEnteros(int total){
        int[] numeros = new int[total];
        Random random = new Random();
        
        //llenar array
        System.out.print( "[ ");
        for(int i=0; i<total; i++){
            numeros[i] = random.nextInt(201) - 100;
            if(i == total - 1){
                System.out.print(numeros[i]);
            }else{
                System.out.print(numeros[i] + ",\t");
            }
            
        }
        System.out.print( "]\n");
        System.out.print( "\n");
        
        buscarSecMax(numeros);
    }
    
    public static void buscarSecMax(int[] numeros){
        int n = numeros.length;
        
        int sumActual = 0;
        int sumMax = 0;
        
        int inicio = 0, fin = 0, temp = 0;
        
        for(int i = 0; i < n; i++){
            sumActual += numeros[i];
            if(sumActual > sumMax){
                sumMax = sumActual;
                inicio  = temp;
                fin = i;
            }
            
            if(sumActual < 0){
                sumActual = 0;
                temp = i + 1;
            }
        }
        
        System.out.print("La suma maxima es: " + sumMax + "\n");
        System.out.print( "\n");
        
        if(sumMax > 0){
            System.out.print("Subsecuencia Maxima: [ ");
            for (int i = inicio; i <= fin; i++) {
                if(i == fin){
                    System.out.print(numeros[i]);
                }else{
                    System.out.print(numeros[i] + ",\t");
                }
            }
            System.out.print("]\n");
            System.out.print("Primer elemento :" + (inicio + 1) + "\n");
            System.out.print("Ultimo elemento :" + (fin + 1) + "\n");
        }else{
            System.out.println("No hay subsecuencia positiva. Por lo tanto la suma máxima es 0.");
        }
    }
    
}
