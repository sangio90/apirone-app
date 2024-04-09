component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="expirationAt" type="Date";
    property name="emissionAt" type="Date";
    property name="assignedAt" type="Date";
    property name="employeeId" type="String";
    property name="company" type="com.apirone.core.model.bean.Company";
    property name="amount" type="Numeric";
    property name="amountSpent" type="Numeric";
    property name="email" type="String";
    property name="phone" type="String";
    property name="status" type="com.apirone.core.model.bean.Status";

    public Card function init(){

        return this;
    }

    public Numeric function getAmountLeft() {

        return getAmount() - getAmountSpent();

    }
}
