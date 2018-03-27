module telegram.ApiResponse;

class ApiResponse(T)
{
    public bool ok;
    public T result;
    public int error_code;
    public string description;
}