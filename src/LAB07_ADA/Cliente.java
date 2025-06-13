
package LAB07_ADA;

/**
 *
 * @author MATHIAS TORRES LEZAMA
 */
public class Cliente {
    private String codigo;
    private String nombres;
    private String apellidos;
    private String telefono;
    private String correo;
    private String direccion;
    private String codigoPostal;
    
    public Cliente(String codigo, String nombres, String apellidos,
                   String telefono, String correo, String direccion,
                   String codigoPostal){
        this.codigo = codigo;
        this.nombres = nombres;
        this.apellidos = apellidos;
        this.telefono = telefono;
        this.correo = correo;
        this.direccion = direccion;
        this.codigoPostal = codigoPostal;
    }
    
    //Getters
    public String getCodigo(){
        return codigo;
    }
    public String getNombres(){
        return nombres;
    }
    public String getApellidos(){
        return apellidos;
    }
    public String getTelefono(){
        return telefono;
    }
    public String getCorreo(){
        return correo;
    }
    public String getDireccion(){
        return direccion;
    }
    public String getCodigoPostal(){
        return codigoPostal;
    }
    
    //Setters
    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }

    public void setNombres(String nombres) {
        this.nombres = nombres;
    }

    public void setApellidos(String apellidos) {
        this.apellidos = apellidos;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public void setCodigoPostal(String codigoPostal) {
        this.codigoPostal = codigoPostal;
    }
    
    @Override
    public String toString(){
        return String.format("%s %s (%s)", nombres, apellidos, codigo);
    }
    
}
