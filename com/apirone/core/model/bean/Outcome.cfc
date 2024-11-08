component accessors="true"  extends="com.apirone.core.model.bean.AbsBean" {

    property name="created" type="Date" default="#now()#";
    property name="status" type="String" default="SUCCESS";
    property name="error";
    property name="message" type="String";
    property name="type" type="String"; // Tipo-di-errore
    property name="data";

}