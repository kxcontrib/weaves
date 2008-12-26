#include <errno.h>
#include <string.h>
#define USE_RINTERNALS
#include <R.h>
#include <Rdefines.h>
#include <Rembedded.h>
#include <Rinternals.h>
#include <k.h>

/*
 * The public interface used from R.
 */
SEXP kx_open_connection(SEXP);
SEXP kx_close_connection(SEXP);
SEXP kx_execute(SEXP c, SEXP);

/*
 * The public interface used from q to control R.
 */
K start_r(K x);
K shutdown_r(K x);
K run_r(K x);


/*
 * A (readable type name, R data type number) pair.
 */
struct data_types {
    char *name;
    Sint id;
};

/*
 * A mapping from readable names to R data type numbers.
 */
const struct data_types r_data_types[] = {
	{"unknown", -1},
	{"NULL", NILSXP}, 
	{"symbol", SYMSXP},
	{"pairlist", LISTSXP},
	{"closure", CLOSXP},
	{"environment", ENVSXP},
	{"promise", PROMSXP},
	{"language", LANGSXP},
	{"special", SPECIALSXP},
	{"builtin", BUILTINSXP},
	{"char", CHARSXP},
	{"logical", LGLSXP},
	{"integer", INTSXP},
	{"double", REALSXP}, 
	{"complex", CPLXSXP},
	{"character", STRSXP},
	{"...", DOTSXP},
	{"any", ANYSXP},
	{"expression", EXPRSXP},
	{"list", VECSXP},
	{"numeric", REALSXP},
	{"name", SYMSXP},
	{0, -1}
};

/*
 * Brute force search of R type table.
 * eg. 	get_type_name(LISTSXP)
 */
char* get_type_name(Sint type)
{
	int i;
	for (i = 1; r_data_types[i].name != 0; i++) {
		if (type == r_data_types[i].id)
			return r_data_types[i].name;
	}
	return r_data_types[0].name;
}

/* 
 * Given the appropriate names, types, and lengths, create an R named list.
 */
SEXP make_named_list(char **names, SEXPTYPE *types, Sint *lengths, Sint n)
{
	SEXP output, output_names, object = NULL_USER_OBJECT;
	Sint elements;
	
	PROTECT(output = NEW_LIST(n));
	PROTECT(output_names = NEW_CHARACTER(n));
	
	int i;
	for(i = 0; i < n; i++){
		elements = lengths[i];
		switch((int)types[i]) {
		case LGLSXP: 
			PROTECT(object = NEW_LOGICAL(elements));
			break;
		case INTSXP:
			PROTECT(object = NEW_INTEGER(elements));
			break;
		case REALSXP:
			PROTECT(object = NEW_NUMERIC(elements));
			break;
		case STRSXP:
			PROTECT(object = NEW_CHARACTER(elements));
			break;
		case VECSXP:
			PROTECT(object = NEW_LIST(elements));
			break;
		default:
			error("Unsupported data type at %d %s\n", __LINE__, __FILE__);
		}
		SET_VECTOR_ELT(output, (Sint)i, object);
		SET_STRING_ELT(output_names, i, COPY_TO_USER_STRING(names[i]));	
	}
	SET_NAMES(output, output_names);
	UNPROTECT(n+2);
	return output;
}

/* 
 * Make a data.frame from a named list by adding row.names, and class 
 * attribute. Uses "1", "2", .. as row.names.
 */
void make_data_frame(SEXP data)
{
	SEXP class_name; 
   
	PROTECT(data);
	PROTECT(class_name = NEW_CHARACTER((Sint) 1));
	SET_STRING_ELT(class_name, 0, COPY_TO_USER_STRING("data.frame"));

	/* Set the row.names. */
	Sint i, n = GET_LENGTH(VECTOR_ELT(data,0));            
	char buffer[1024];
	SEXP row_names; 
	PROTECT(row_names = NEW_CHARACTER(n));
	for(i = 0; i < n; i++) {
      	(void) sprintf(buffer, "%d", i+1);
      	SET_STRING_ELT(row_names, i, COPY_TO_USER_STRING(buffer));
   }
   setAttrib(data, R_RowNamesSymbol, row_names);
   SET_CLASS(data, class_name);
   UNPROTECT(3);
}

/*
 * We have functions that turn any K object from kdb+ into the appropriate
 * R object type.
 */
static K from_any_robject(SEXP);
static K error_broken_robject(SEXP);
static K from_null_robject(SEXP);
static K from_symbol_robject(SEXP); 
static K from_pairlist_robject(SEXP); 
static K from_closure_robject(SEXP); 
static K from_environment_robject(SEXP); 
static K from_promise_robject(SEXP); 
static K from_language_robject(SEXP); 
static K from_builtin_robject(SEXP); 
static K from_char_robject(SEXP); 
static K from_logical_robject(SEXP); 
static K from_integer_robject(SEXP); 
static K from_double_robject(SEXP); 
static K from_complex_robject(SEXP); 
static K from_character_robject(SEXP); 
static K from_dot_robject(SEXP); 
static K from_expression_robject(SEXP); 
static K from_list_robject(SEXP); 
static K from_vector_robject(SEXP); 
static K from_numeric_robject(SEXP); 
static K from_any_robject(SEXP); 
static K from_name_robject(SEXP); 

/*
 * We have functions that turn any R object from kdb+ into the appropriate
 * kdb+ K object type.
 */
static SEXP from_any_kobject(K object);
static SEXP error_broken_kobject(K);
static SEXP from_list_of_kobjects(K);
static SEXP from_bool_kobject(K);
static SEXP from_byte_kobject(K);
static SEXP from_string_kobject(K);
static SEXP from_short_kobject(K);
static SEXP from_int_kobject(K);
static SEXP from_long_kobject(K);
static SEXP from_float_kobject(K);
static SEXP from_double_kobject(K);
static SEXP from_symbol_kobject(K);
static SEXP from_month_kobject(K);
static SEXP from_date_kobject(K);
static SEXP from_datetime_kobject(K);
static SEXP from_minute_kobject(K);
static SEXP from_second_kobject(K);
static SEXP from_time_kobject(K);
static SEXP from_dictionary_kobject(K);
static SEXP from_table_kobject(K);

/*
 * An array of functions that deal with kdbplus data types. Note that the order
 * is very important as we index it based on the kdb+ type number in the K object.
 */
#define number_of_k_types 20
 
typedef SEXP(*conversion_function)(K);

conversion_function kdbplus_types[] = {
	from_list_of_kobjects, 
	from_bool_kobject, 
	error_broken_kobject, 
	error_broken_kobject, 
	from_byte_kobject, 
	from_short_kobject, 
	from_int_kobject, 
	from_long_kobject, 
	from_float_kobject, 
	from_double_kobject, 
	from_string_kobject, 
	from_symbol_kobject, 
	error_broken_kobject, 
	from_month_kobject, 
	from_date_kobject, 
	from_datetime_kobject, 
	error_broken_kobject, 
	from_minute_kobject,
	from_second_kobject, 
	from_time_kobject 
};
	
/*
 * Convert any K object returned from kdb+ into an R object by 
 * dispatching on the K type.
 */
static SEXP from_any_kobject(K x)
{
	SEXP result;
	int type = abs(x->t);
	if (98 == type)
		result = from_table_kobject(x);
	else if (99 == type)
		result = from_dictionary_kobject(x);
	else if (105 == type || 101 == type)
		result = from_int_kobject(ki(0));
	else if (-1 < type && type < 20)
		result = kdbplus_types[type](x);
	else
		result = error_broken_kobject(x);
	return result;	
}

/*
 * Complain that the given K object is not valid and return "unknown".
 */
static SEXP error_broken_kobject(K broken)
{
	error("Value is not a valid kdb+ object; unknown type %d\n", broken->t);
	r0(broken);
	mkChar(r_data_types[0].name);
}


static SEXP from_list_of_kobjects(K x)
{
	SEXP result;
	int i, length = x->n;
	PROTECT(result = NEW_LIST(length));
	for (i = 0; i < length; i++)
		SET_VECTOR_ELT(result, i, from_any_kobject(r1(xK[i]))); 
	r0(x);
	UNPROTECT(1);
	return result;
}

/*
 * NB.
 *
 * These next functions have 2 main control flow paths. One for scalars and
 * one for vectors. Because of the way the data is laid out in k objects, its
 * not possible to combine them.
 *
 * We always decrement the reference count of the object as it will have been
 * incremented in the initial dispatch.
 *
 * We promote shorts and floats to larger types when converting to R (ints and
 * doubles respectively).
 */
 
/*
 * Is the given k object a scalar or vector?
 */ 
#define scalar(x) (x->t < 0)
 
static SEXP from_bool_kobject(K x)
{
	SEXP result;
	int i, length = x->n;
	if (scalar(x)) {
		PROTECT(result = NEW_LOGICAL(1));
		LOGICAL_POINTER(result)[0] = x->g;
	} 
	else {
		PROTECT(result = NEW_LOGICAL(length));
		int i;
		for(i = 0; i < length; i++)
			LOGICAL_POINTER(result)[i] = x->G0[i];
	}
	UNPROTECT(1);
	return result;
}

static SEXP from_byte_kobject(K x)
{
	SEXP result;
	int i, length = x->n;
	if (scalar(x)) {
		PROTECT(result = NEW_INTEGER(1));
		INTEGER_POINTER(result)[0] = (int) x->g;
	} 
	else {
		PROTECT(result = NEW_INTEGER(length));
		for(i = 0; i < length; i++)
			INTEGER_POINTER(result)[i] = x->G0[i];
	}
	UNPROTECT(1);
	return result;
}

static SEXP from_short_kobject(K x)
{
	SEXP result;
	int i, length = x->n;
	if (scalar(x)) {
		PROTECT(result = NEW_INTEGER(1));
		INTEGER_POINTER(result)[0] = (int) x->h;
	} 
	else {
		PROTECT(result = NEW_INTEGER(xn));
		for(i = 0; i < length; i++)
			INTEGER_POINTER(result)[i] = (int) xH[i];					
	}
	UNPROTECT(1);
	return result;
}

static SEXP from_int_kobject(K x)
{
	SEXP result;
	int i, length = x->n;
	if (scalar(x)) {
		PROTECT(result = NEW_INTEGER(1));
		INTEGER_POINTER(result)[0] = x->i;
	} 
	else {
		PROTECT(result = NEW_INTEGER(length));
		for(i = 0; i < length; i++) 
			INTEGER_POINTER(result)[i] = (int) xI[i];	
	}
	UNPROTECT(1);
	return result;
}

static SEXP from_long_kobject(K x)
{
	SEXP result;
	int i, length = x->n;
	if (scalar(x)) {
		PROTECT(result = NEW_NUMERIC(1));
		NUMERIC_POINTER(result)[0] = (double) x->j;
	} 
	else {
		PROTECT(result = NEW_NUMERIC(length));
		for(i = 0; i < length; i++)
			NUMERIC_POINTER(result)[i] = (double) xJ[i];
	}
	UNPROTECT(1);
	return result;
}

static SEXP from_float_kobject(K x)
{
	SEXP result;
	int i, length = x->n;
	if (scalar(x)) {
		PROTECT(result = NEW_NUMERIC(1));
		NUMERIC_POINTER(result)[0] = (double) x->e;
	} 
	else {
		PROTECT(result = NEW_NUMERIC(length));
		for(i = 0; i < length; i++)
			NUMERIC_POINTER(result)[i] = (double) xE[i];
	}
	UNPROTECT(1);
	return result;
}

static SEXP from_double_kobject(K x)
{
	SEXP result;
	int i, length = x->n;
	if (scalar(x)) {
		PROTECT(result = NEW_NUMERIC(1));
		NUMERIC_POINTER(result)[0] = x->f;
	} 
	else {
		PROTECT(result = NEW_NUMERIC(length));
		for(i = 0; i < length; i++)
			NUMERIC_POINTER(result)[i] = xF[i];
	}
	UNPROTECT(1);
	return result;
}

static SEXP from_string_kobject(K x)
{
	SEXP result;
	int i, length = x->n;
	if (scalar(x)) {
		char buffer[2];
		PROTECT(result = NEW_CHARACTER(1));
		buffer[0] = x->g;
		buffer[1] = '\0';
		SET_STRING_ELT(result, 0, mkChar(buffer));
	} 
	else {
		char *buffer;
		PROTECT(result = allocVector(STRSXP, 1));
		buffer = calloc(length + 1, 1);
		memcpy(buffer, xG, length);
		buffer[length] = '\0';
		SET_STRING_ELT(result, 0, mkChar(buffer));
		free(buffer);
	}; 
	UNPROTECT(1);
	return result;
}

static SEXP from_symbol_kobject(K x)
{
	SEXP result;
	int i, length = x->n;
	if (scalar(x)) {
		PROTECT(result = NEW_CHARACTER(1));
		SET_STRING_ELT(result, 0, mkChar(xs));
	} 
	else {
		PROTECT(result = NEW_CHARACTER(length));
		for(i = 0; i < length; i++)
			SET_STRING_ELT(result, i, mkChar(xS[i]));
	}
	UNPROTECT(1);
	return result;
}

/*
 * NB. Makes no attempt to turn it into a more meaningful R object.
 */	
static SEXP from_month_kobject(K object) 
{
	return from_int_kobject(object);	
}

/*
 * NB. Makes no attempt to turn it into a more meaningful R object.
 */	
static SEXP from_date_kobject(K object) 
{
	return from_int_kobject(object);
}

/*
 * NB. Makes no attempt to turn it into a more meaningful R object.
 * We convert the kdb+ time into number of seconds since epoch.
 */	
static SEXP from_datetime_kobject(K x) 
{
	SEXP result;
	PROTECT(result = NEW_INTEGER(1));
	INTEGER_POINTER(result)[0] = 86400*(x->f+10957);
	r0(x);
	UNPROTECT(1);
	return result;	
}

/*
 * NB. Makes no attempt to turn it into a more meaningful R object.
 */	
static SEXP from_minute_kobject(K object) 
{
	return from_int_kobject(object);	
}

/*
 * NB. Makes no attempt to turn it into a more meaningful R object.
 */	
static SEXP from_second_kobject(K object) 
{
	return from_int_kobject(object);	
}

/*
 * NB. Makes no attempt to turn it into a more meaningful R object.
 */	
static SEXP from_time_kobject(K object) 
{
	return from_int_kobject(object);	
}

static SEXP from_dictionary_kobject(K x)
{
	SEXP names, result;
	
	/* Try to create a simple table from a keyed table.. */
	K table;
	if ((table = ktd(x)))
		return from_table_kobject(table);
	
	/* ..if the previous attempt to convert from a keyed table failed, x is still valid. */
	PROTECT(names = from_any_kobject(r1(xx)));
	PROTECT(result = from_any_kobject(r1(xy)));
	SET_NAMES(result, names);
	
	r0(x); 
	UNPROTECT(2);
	return result;
}

static SEXP from_table_kobject(K x)
{
	SEXP result;
	PROTECT(result = from_dictionary_kobject(r1(xk)));
	r0(x);
	UNPROTECT(1);
	make_data_frame(result);
	return result;
}

static K from_any_robject(SEXP expression)
{
	K result = 0;
	int type = TYPEOF(expression); // expression->sxpinfo.type;
	switch (type) {
	case NILSXP : return from_null_robject(expression); break; 	/* nil = NULL */
	case SYMSXP : return from_symbol_robject(expression); break;    /* symbols */
	case LISTSXP : return from_list_robject(expression); break; 	/* lists of dotted pairs */
	case CLOSXP : return from_closure_robject(expression); break;		/* closures */
	case ENVSXP : return from_environment_robject(expression); break;		/* environments */
	case PROMSXP : return from_promise_robject(expression); break; 	/* promises: [un]evaluated closure arguments */
	case LANGSXP : return from_language_robject(expression); break; 	/* language constructs (special lists) */
	case SPECIALSXP : return error_broken_robject(expression); break; 	/* special forms */
	case BUILTINSXP : return error_broken_robject(expression); break; 	/* builtin non-special forms */
	case CHARSXP : return from_char_robject(expression); break; 	/* "scalar" string type (internal only)*/
	case LGLSXP : return from_logical_robject(expression); break; 	/* logical vectors */
	case INTSXP : return from_integer_robject(expression); break; 	/* integer vectors */
	case REALSXP : return from_double_robject(expression); break; 	/* real variables */
	case CPLXSXP : return from_complex_robject(expression); break; 	/* complex variables */
	case STRSXP : return from_character_robject(expression); break; 	/* string vectors */
	case DOTSXP : return from_dot_robject(expression); break; 	/* dot-dot-dot object */
	case ANYSXP : return error_broken_robject(expression); break; 	/* make "any" args work */
	case VECSXP : return from_vector_robject(expression); break; 	/* generic vectors */
	case EXPRSXP : return from_expression_robject(expression); break; 	/* expressions vectors */
	case BCODESXP : return error_broken_robject(expression); break; 	/* byte code */
	case EXTPTRSXP : return error_broken_robject(expression); break; 	/* external pointer */
	case WEAKREFSXP : return error_broken_robject(expression); break; 	/* weak reference */
	case RAWSXP : return error_broken_robject(expression); break; 	/* raw bytes */
	case S4SXP : return error_broken_robject(expression); break; 	/* S4 non-vector */
	case FUNSXP : return error_broken_robject(expression); break; 	/* Closure or Builtin */
	}
	return result;
}

static K error_broken_robject(SEXP expression)
{
	return krr("Broken R object.");
}

static K from_null_robject(SEXP expression)
{
	return ki((int)0x80000000);
}

static K from_symbol_robject(SEXP expression) 
{
	return kp("symbol");
}

static K from_pairlist_robject(SEXP expression) 
{
	return kp("pairlist");
}

static K from_closure_robject(SEXP expression) 
{
	return kp("closure");
}

static K from_environment_robject(SEXP expression) 
{
	return kp("environment");
}

static K from_promise_robject(SEXP expression) 
{
	return kp("promise");
}

static K from_language_robject(SEXP expression)  
{
	return kp("language");
}

static K from_builtin_robject(SEXP expression) 
{
	return kp("builtin");
}

static K from_char_robject(SEXP expression) 
{
	return kp("char");
}

static K from_logical_robject(SEXP expression) 
{
	int i, length = LENGTH(expression);
	K result = ktn(KI, length);
	for(i = 0; i < length; ++i)
		kI(result)[i] = LOGICAL_POINTER(expression)[i];
	return result;
}

static K from_integer_robject(SEXP expression)
{
	int i, length = LENGTH(expression);
	K result = ktn(KI, length);
	for(i = 0; i < length; ++i)
		kI(result)[i] = INTEGER_POINTER(expression)[i];
	return result;
}

static K from_double_robject(SEXP expression)
{
	int i, length = LENGTH(expression);
	K result = ktn(KF, length);
	for(i = 0; i < length; ++i)
		kF(result)[i] = REAL(expression)[i];
	return result;
}

static K from_complex_robject(SEXP expression) 
{
	return kp("complex");
}

static K from_character_robject(SEXP expression) 
{
	int i, length = LENGTH(expression);
	K x = ktn(0, length);
	for (i = 0; i < length; i++) {
		xK[i] = kp(CHAR(STRING_ELT(expression,i)));
	}	
	return x;
}

static K from_dot_robject(SEXP expression) 
{
	return kp("pairlist");
}

static K from_expression_robject(SEXP expression) 
{
	return kp("dot");
}

static K from_list_robject(SEXP expression) 
{
	return kp("list");
}

static K from_vector_robject(SEXP expression) 
{
	int i, length = LENGTH(expression);
	K x = ktn(0, length);
	for (i = 0; i < length; i++) {
		xK[i] = from_any_robject(VECTOR_ELT(expression, i));
	}	
	return x;
}

static K from_numeric_robject(SEXP expression) 
{
	return kp("numeric");
}

static K from_name_robject(SEXP expression)
{
	return kp("name");
}
 

/*
 * NB. These are the public interface functions when calling
 *     from R to a running kdb+ process.
 */
 
/*
 * Open a connection to an existing kdb+ process.
 *
 * If we just have a host and port we call khp from the kdb+ interface.
 * If we have a host, port, "username:password" we call instead khpu.
 */
SEXP kx_open_connection(SEXP whence)
{
	int length = GET_LENGTH(whence);
	if (length < 2)
		error("Can't connect with so few parameters..");

	SEXP result;		
	int connection, port = INTEGER_POINTER (VECTOR_ELT(whence, 1))[0];
	char *host = CHARACTER_VALUE(VECTOR_ELT(whence, 0));
	
	if (2 == length) 
		connection = khp(host, port);
	else {
		char *user = CHARACTER_VALUE (VECTOR_ELT (whence, 2));
		connection = khpu(host, port, user);
	}
	
	PROTECT(result = NEW_INTEGER(1));
	INTEGER_POINTER(result)[0] = connection;
	UNPROTECT(1);
	return result;
}

/*
 * Close a connection to an existing kdb+ process.
 *
 */
SEXP kx_close_connection(SEXP connection)
{
	SEXP result;
	
	/* Close the connection. */
	int e = closesocket(INTEGER_VALUE(connection));
	if (-1 == e) {
		/* Complain using the translated errno. */
		error(strerror(errno));
	}
	PROTECT(result = NEW_INTEGER(1));
	INTEGER_POINTER(result)[0] = e;
	UNPROTECT(1);
	return result;
}

/*
 * Execute a kdb+ query over the given connection.
 */
SEXP kx_execute(SEXP connection, SEXP query)
{
	K result;
	result = k(INTEGER_VALUE(connection), CHARACTER_VALUE(query), 0);
	if (-128 == result->t) {
		/* Release the k object as we're not returning it.. */
		r0(result);
		/* .. we shouldn't access it here, but its convenient.. and we'll almost certainly
		   always get away with it. */
		error("Error from kdb+: %s\n", result->s);
	}
	return from_any_kobject(result);
}

/*
 * NB. These are the functions to control R from within kdb+.
 */
 

/*
 * First, we borrow access to several variables defined by R to
 * control how it operates.
 */
 
extern Rboolean R_Interactive;  /* TRUE during interactive use*/
Rboolean R_Quiet;        /* Be as quiet as possible */
extern Rboolean R_Slave;        /* Run as a slave process */
Rboolean R_Verbose;      /* Be verbose */

/*
 * We need to borrow several of the R runtime functions as well.
 * Note this is a tad fragile - there is no guarantee that these
 * will not change from R release to release.
 *
 * I dragged in anything that looked like fun for now.
 */
 
extern void R_RestoreGlobalEnv(void);
extern void R_RestoreGlobalEnvFromFile(const char *, Rboolean);
extern void R_SaveGlobalEnv(void);
extern void R_SaveGlobalEnvToFile(const char *);
extern void R_FlushConsole(void);
extern void R_ClearerrConsole(void);
extern void R_Suicide(char*);
extern char* R_HomeDir(void);
extern int R_DirtyImage;        
extern char* R_GUIType;
extern void R_setupHistory();
extern char* R_HistoryFile;     
extern int R_HistorySize;      
extern int R_RestoreHistory;    
extern char* R_Home;           
extern void (*ptr_R_Suicide)(char *);
extern void (*ptr_R_ShowMessage)(char *);
extern int  (*ptr_R_ReadConsole)(char *, unsigned char *, int, int);
extern void (*ptr_R_WriteConsole)(char *, int);
extern void (*ptr_R_ResetConsole)();
extern void (*ptr_R_FlushConsole)();
extern void (*ptr_R_ClearerrConsole)();
extern void (*ptr_R_Busy)(int);
extern int  (*R_timeout_handler)();
extern long R_timeout_val;
extern void Rf_CleanEd(void);
extern int  R_CollectWarnings;          
extern void Rf_PrintWarnings(void);
extern int Rf_resetStack(int);

SEXP eval_r_expression(SEXP expression);
SEXP lookup_r_function(char *name);

/* 
 * Evaluate a given zero argument function.
 */
SEXP eval_r_command(char *name) 
{
	SEXP expression, function, result;

	function = lookup_r_function(name);
	if (!function)
		return NULL;

	PROTECT(function);
	PROTECT(expression = allocVector(LANGSXP, 1));
	SETCAR(expression, function);

	PROTECT(result = eval_r_expression(expression));
	UNPROTECT(3);
	return result;
}

/*
 * Evaluate the given R expression in the global R environment.
 */
SEXP eval_r_expression(SEXP expression) 
{
	int error = 0;
	SEXP result = R_tryEval(expression, R_GlobalEnv, &error);
	if (error) {
		return eval_r_command("geterrmessage");
	}
  	return result;
}

/*
 * Lookup an R function object by its name. 
 */
SEXP lookup_r_function(char *name) 
{
	/* 
	 * R is touchy; we need to check the identifier for
	 * null or being too long.
	 */
	if (!*name || strlen(name) > 256)
		return NULL;
  
	/*
	 * Seems to be 2 ways this can happen - documentation is
	 * vague but this is safe from what I can tell browsing
	 * their source.
	 */
	SEXP object = Rf_findVar(Rf_install(name), R_GlobalEnv);
	if (object != R_UnboundValue)
		object = Rf_findFun(Rf_install(name), R_GlobalEnv);
  
	if (object == R_UnboundValue) 
    	return NULL;
	else
		return object;
}

/*
 * Get R's last complaint.
 */
K last_r_error() 
{
  SEXP error;
  error = eval_r_command("geterrmessage");
  return kp(CHARACTER_VALUE(error));
}

#define BUFFER_SIZE 1024
static char RHOME[BUFFER_SIZE];
static char RVERSION[BUFFER_SIZE];
static char RVER[BUFFER_SIZE];
static char RUSER[BUFFER_SIZE];

/*
 * Place to stash things we want to protect from the garbage collector.
 */
static SEXP R_References;

static SEXP recursively_release_robjects(SEXP object, SEXP list)
{
	if (!isNull(list)) 
		if (object == CAR(list)) return CDR(list);
		else SETCDR(list, recursively_release_robjects(object, CDR(list)));
	return list;
}

/*
 * Release some SEXP whose address has been wrapped inside a K object.
 */
K release_r_object(K x)
{
	if (-KJ != x->j)
		return krr("Wrong type; should be a pointer encoded as a long.");
	R_References = recursively_release_robjects((SEXP)(x->j), R_References);
	SET_SYMVALUE(install("R.References"), R_References);
	return 0;
}

/* 
 * Protect the R object and wrap it's address inside a K object. 
 */
K new_wrapped_sexp(SEXP object)
{
	R_References = CONS(object, R_References);
	SET_SYMVALUE(install("R.References"), R_References);
	return kj((long)object);
}

/*
 * Silently start R under the covers for use from kdb+.
 */
K start_r(K x)
{
	char *argv[]= {"REmbedded", "--silent"};
	Rf_initEmbeddedR(sizeof(argv)/sizeof(argv[0]), argv);
	/* Use the R truth values here in case they change them for some reason. */
	R_Interactive = TRUE;
	R_Quiet = TRUE; 
	R_Slave = TRUE;
	R_Verbose = TRUE;
} 

/*
 * Shutdown R; let it go out in a blaze of glory.
 */
K shutdown_r(K x)
{
	unsigned char buffer[BUFFER_SIZE];
	char *tmpdir;

	R_dot_Last();           
	R_RunExitFinalizers();  
	Rf_CleanEd();              
	Rf_KillAllDevices();
	
	/*
	 * I always did want to do "rm -rf" from the bowels of a shared library.
	 */       
	if((tmpdir = getenv("R_SESSION_TMPDIR"))) {          
		snprintf((char*)buffer, 1024, "rm -rf %s", tmpdir);
		R_system((char*)buffer);
	}
	
	Rf_PrintWarnings();
	R_gc();
	Rf_endEmbeddedR(0);
} 

/*
 * R seems to want this defined. We disdainfully ignore it.
 */
void jump_now(void)
{
	// Reset the stack?
}

/*
 * Take a copy of the string held in x.
 */
static char* copy(K x) {
	char *result = "";
	size_t length;
	if (-KS == x->t) {
		length = strlen(x->s);
		result = calloc(length, sizeof(char));
		strcpy(result, x->s);
	}
	else if (KC == x->t) {
		length = x->n;
		result = calloc(length, sizeof(char));
		strncpy(result, kC(x), length);
	}
	else if (-KC == x->t) {
		length = 2;
		result = calloc(length, sizeof(char));
		result[0] = x->g;
	}
	return result;
}

/*
 * Call the R function "fun" with the given args.
 */
SEXP call_r_function(SEXP fun, SEXP args)
{
	int i;
	SEXP c, call, result;
	long n = Rf_length(args);
	if(n > 0) {
		PROTECT(c = call = Rf_allocList(n));
		for (i = 0; i < n; i++) {
			SETCAR(c, VECTOR_ELT(args, i));
			c = CDR(c);
		}
	call = Rf_lcons(fun, call);
	UNPROTECT(1);
	} else  {
		call = Rf_allocVector(LANGSXP,1);
		SETCAR(call, fun);
	}  

	PROTECT(call);
	result = Rf_eval(call, R_GlobalEnv);
	UNPROTECT(1);

	return result;     
} 

/*
 * Parse the given text as an R expression.
 */
SEXP parse_function(const char *body)
{
	SEXP args;
	SEXP txt;
	SEXP function = lookup_r_function("parse_function");
	PROTECT(function);
	PROTECT(txt = NEW_CHARACTER(1));
	SET_STRING_ELT(txt, 0, COPY_TO_USER_STRING(body));
	PROTECT(args = NEW_LIST(1));
	SET_VECTOR_ELT(args, 0, txt);
	function = call_r_function(function, args);
	UNPROTECT(2);
	return(function);
}

/*
 * Run a single R statement.
 */
K run_r(K x) 
{
	char *command = copy(x);
	int status;
	SEXP sexp = parse_function(command);
	free(command);
	SEXP result = eval_r_expression(sexp);
	return from_any_robject(result); 
}

/*
 * Find the given name in the global R environment.
 */
static SEXP get_var_in_r(SEXP name)
{
       SEXP result;
     
       if(!isString(name) || length(name) != 1)
         error("name is not a single string");
       result = findVar(install(CHAR(STRING_ELT(name, 0))), R_GlobalEnv);
       return result;
}

/*
 * Bind a K object to some SEXP.
 */
K bind_in_r(K x, K y) 
{
	char *n = copy(x);
	SEXP name = PROTECT(mkString(n));
	SEXP value = PROTECT(from_any_kobject(y));
	defineVar(install(n), value, R_GlobalEnv);
	free(n);
	UNPROTECT(2);
	return 0;
}

/*
 * Get the named object from R.
 */
K get_from_r(K x) 
{
	char *n = copy(x);
	SEXP name = PROTECT(mkString(n));
	SEXP value = get_var_in_r(name);
	K result = from_any_robject(value);
	UNPROTECT(1);
	return result;
}

