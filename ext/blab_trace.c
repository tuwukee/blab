#include "extconf.h"

#define TRUE 1
#define FALSE 0

PUREFUNC(static rb_callable_method_entry_t *check_method_entry(VALUE obj, int can_be_svar));
static rb_callable_method_entry_t *check_method_entry(VALUE obj, int can_be_svar)
{
    if (obj == Qfalse) return NULL;

#if VM_CHECK_MODE > 0
    if (!RB_TYPE_P(obj, T_IMEMO)) rb_bug("check_method_entry: unknown type: %s", rb_obj_info(obj));
#endif

    switch (imemo_type(obj)) {
      case imemo_ment:
    return (rb_callable_method_entry_t *)obj;
      case imemo_cref:
    return NULL;
      case imemo_svar:
    if (can_be_svar) {
        return check_method_entry(((struct vm_svar *)obj)->cref_or_me, FALSE);
    }
      default:
#if VM_CHECK_MODE > 0
    rb_bug("check_method_entry: svar should not be there:");
#endif
    return NULL;
    }
}


MJIT_STATIC const rb_callable_method_entry_t *rb_vm_frame_method_entry(const rb_control_frame_t *cfp)
{
    const VALUE *ep = cfp->ep;
    rb_callable_method_entry_t *me;

    while (!VM_ENV_LOCAL_P(ep)) {
    if ((me = check_method_entry(ep[VM_ENV_DATA_INDEX_ME_CREF], FALSE)) != NULL) return me;
    ep = VM_ENV_PREV_EP(ep);
    }

    return check_method_entry(ep[VM_ENV_DATA_INDEX_ME_CREF], TRUE);
}


int rb_vm_control_frame_id_and_class(const rb_control_frame_t *cfp, ID *idp, ID *called_idp, VALUE *klassp)
{
    const rb_callable_method_entry_t *me = rb_vm_frame_method_entry(cfp);

    if (me) {
    if (idp) *idp = me->def->original_id;
    if (called_idp) *called_idp = me->called_id;
    if (klassp) *klassp = me->owner;
    return TRUE;
    }
    else {
    return FALSE;
    }
}

int rb_ec_frame_method_id_and_class(const rb_execution_context_t *ec, ID *idp, ID *called_idp, VALUE *klassp)
{
    return rb_vm_control_frame_id_and_class(ec->cfp, idp, called_idp, klassp);
}

inline static int calc_lineno(const rb_iseq_t *iseq, const VALUE *pc)
{
    size_t pos = (size_t)(pc - iseq->body->iseq_encoded);
    if (LIKELY(pos)) {
        /* use pos-1 because PC points next instruction at the beginning of instruction */
        pos--;
    }
#if VMDEBUG && defined(HAVE_BUILTIN___BUILTIN_TRAP)
    else {
        /* SDR() is not possible; that causes infinite loop. */
        rb_print_backtrace();
        __builtin_trap();
    }
#endif
    return rb_iseq_line_no(iseq, pos);
}

int rb_vm_get_sourceline(const rb_control_frame_t *cfp)
{
    if (VM_FRAME_RUBYFRAME_P(cfp) && cfp->iseq) {
    const rb_iseq_t *iseq = cfp->iseq;
    int line = calc_lineno(iseq, cfp->pc);
    if (line != 0) {
        return line;
    }
    else {
        return FIX2INT(rb_iseq_first_lineno(iseq));
    }
    }
    else {
    return 0;
    }
}

static const char * get_event_name(rb_event_flag_t event)
{
    switch (event) {
      case RUBY_EVENT_LINE:     return "line";
      case RUBY_EVENT_CLASS:    return "class";
      case RUBY_EVENT_END:      return "end";
      case RUBY_EVENT_CALL:     return "call";
      case RUBY_EVENT_RETURN:   return "return";
      case RUBY_EVENT_C_CALL:   return "c-call";
      case RUBY_EVENT_C_RETURN: return "c-return";
      case RUBY_EVENT_RAISE:    return "raise";
      default:
    return "unknown";
    }
}

static void get_path_and_lineno(const rb_execution_context_t *ec, const rb_control_frame_t *cfp, rb_event_flag_t event, VALUE *pathp, int *linep)
{
    cfp = rb_vm_get_ruby_level_next_cfp(ec, cfp);

    if (cfp) {
    const rb_iseq_t *iseq = cfp->iseq;
    *pathp = rb_iseq_path(iseq);

    if (event & (RUBY_EVENT_CLASS |
                RUBY_EVENT_CALL  |
                RUBY_EVENT_B_CALL)) {
        *linep = FIX2INT(rb_iseq_first_lineno(iseq));
    }
    else {
        *linep = rb_vm_get_sourceline(cfp);
    }
    }
    else {
    *pathp = Qnil;
    *linep = 0;
    }
}

static void call_trace_func(rb_event_flag_t event, VALUE proc, VALUE self, ID id, VALUE klass)
{
    int line;
    VALUE filename;
    VALUE eventname = rb_str_new2(get_event_name(event));
    VALUE argv[6];
    const rb_execution_context_t *ec = GET_EC();

    get_path_and_lineno(ec, ec->cfp, event, &filename, &line);

    if (!klass) {
    rb_ec_frame_method_id_and_class(ec, &id, 0, &klass);
    }

    if (klass) {
    if (RB_TYPE_P(klass, T_ICLASS)) {
        klass = RBASIC(klass)->klass;
    }
    else if (FL_TEST(klass, FL_SINGLETON)) {
        klass = rb_ivar_get(klass, id__attached__);
    }
    }

    argv[0] = eventname;
    argv[1] = filename;
    argv[2] = INT2FIX(line);
    argv[3] = id ? ID2SYM(id) : Qnil;
    argv[4] = (self && (filename != Qnil)) ? rb_binding_new() : Qnil;
    argv[5] = klass ? klass : Qnil;

    rb_proc_call_with_block(proc, 6, argv, Qnil);
}

static VALUE rb_blab_trace(VALUE obj, VALUE trace)
{
    rb_remove_event_hook(call_trace_func);

    if (NIL_P(trace)) {
        return Qnil;
    }

    if (!rb_obj_is_proc(trace)) {
        rb_raise(rb_eTypeError, "trace_func needs to be Proc");
    }

    rb_add_event_hook(call_trace_func, RUBY_EVENT_ALL, trace);
    return trace;
}

void Init_blab_trace()
{
    rb_define_global_function("blab_trace", rb_blab_trace, 1);
}
