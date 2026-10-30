'use client';
import {useEffect,useMemo,useState} from 'react';
import Link from 'next/link';
import {supabase} from '@/lib/supabase';
import {Header,Footer} from '@/components/Site';

type Subscriber={email:string;created_at?:string};
type Visit={created_at:string;path:string};
type Row=Record<string,any>;

const categories=['Rwanda Basketball','Rwanda Basketball League','BAL','Patriots','REG','APR',"Women's League",'NBA','FIBA','EuroLeague','Videos','Opinion'];
const blank:Row={title:'',excerpt:'',content:'',category:'Rwanda Basketball',language:'rw',image_url:'',status:'draft',tags:[]};

function dayKey(d:Date){return d.getFullYear()+'-'+String(d.getMonth()+1).padStart(2,'0')+'-'+String(d.getDate()).padStart(2,'0')}

function TrafficChart({visits}:{visits:Visit[]}){
  const days=30;
  const data=useMemo(()=>{
    const start=new Date();
    start.setHours(0,0,0,0);
    start.setDate(start.getDate()-(days-1));
    const map=new Map<string,number>();
    for(let i=0;i<days;i++){const d=new Date(start);d.setDate(start.getDate()+i);map.set(dayKey(d),0)}
    visits.forEach(v=>{const k=dayKey(new Date(v.created_at));if(map.has(k))map.set(k,(map.get(k)||0)+1)});
    const buckets=[...map.entries()].map(([key,count])=>({key,count,date:new Date(key+'T00:00:00')}));
    const max=Math.max(1,...buckets.map(b=>b.count));
    const total=buckets.reduce((s,b)=>s+b.count,0);
    const last7=buckets.slice(-7).reduce((s,b)=>s+b.count,0);
    const today=buckets[buckets.length-1]?.count||0;
    return {buckets,max,total,last7,today};
  },[visits]);

  const W=760,H=250,padL=44,padR=16,padT=18,padB=40;
  const plotW=W-padL-padR,plotH=H-padT-padB;
  const pts=data.buckets.map((b,i)=>({...b,x:padL+(i/(days-1))*plotW,y:padT+plotH-(b.count/data.max)*plotH}));
  const line=pts.map(p=>p.x.toFixed(1)+','+p.y.toFixed(1)).join(' ');
  const area=padL+','+(padT+plotH)+' '+line+' '+(padL+plotW)+','+(padT+plotH);

  return <div>
    <div className="statgrid" style={{marginBottom:16}}>
      <div className="stat"><span className="meta">Today</span><strong>{data.today}</strong><small>Page views</small></div>
      <div className="stat"><span className="meta">Last 7 days</span><strong>{data.last7}</strong><small>Page views</small></div>
      <div className="stat"><span className="meta">Last 30 days</span><strong>{data.total}</strong><small>Page views</small></div>
    </div>
    <div style={{overflowX:'auto'}}>
      <svg viewBox={'0 0 '+W+' '+H} role="img" aria-label="Visitors over the last 30 days" style={{width:'100%',minWidth:560,height:'auto',display:'block'}}>
        {[0,0.25,0.5,0.75,1].map(f=>{const y=padT+plotH*f;return <g key={f}><line x1={padL} x2={padL+plotW} y1={y} y2={y} stroke="#eee"/><text x={padL-8} y={y+4} textAnchor="end" fontSize="10" fill="#888">{Math.round(data.max*(1-f))}</text></g>})}
        <polygon points={area} fill="rgba(244,81,30,.12)"/>
        <polyline points={line} fill="none" stroke="#f4511e" strokeWidth="2.5" strokeLinejoin="round"/>
        {pts.map((p,i)=><circle key={p.key} cx={p.x} cy={p.y} r={p.count?3:0} fill="#f4511e"><title>{p.date.toLocaleDateString()} — {p.count} view{p.count===1?'':'s'}</title></circle>)}
        {pts.map((p,i)=>(i%5===0||i===days-1)?<text key={'l'+p.key} x={p.x} y={H-16} textAnchor="middle" fontSize="10" fill="#888">{p.date.toLocaleDateString('en',{day:'2-digit',month:'short'})}</text>:null)}
      </svg>
    </div>
  </div>;
}

export default function Admin(){
  const [session,setSession]=useState<any>(null);
  const [email,setEmail]=useState('');
  const [password,setPassword]=useState('');
  const [articles,setArticles]=useState<Row[]>([]);
  const [form,setForm]=useState<Row>(blank);
  const [editing,setEditing]=useState<string|null>(null);
  const [msg,setMsg]=useState('');
  const [stats,setStats]=useState({views:0,articles:0,comments:0,subscribers:0});
  const [visits,setVisits]=useState<Visit[]>([]);
  const [subscribers,setSubscribers]=useState<Subscriber[]>([]);
  const [tab,setTab]=useState('articles');
  const [uploading,setUploading]=useState(false);
  const [busy,setBusy]=useState(false);
  const [role,setRole]=useState('');

  useEffect(()=>{
    if(!supabase)return;
    supabase.auth.getSession().then(({data})=>setSession(data.session));
    const {data:listener}=supabase.auth.onAuthStateChange((_e,s)=>setSession(s));
    return()=>listener.subscription.unsubscribe();
  },[]);

  useEffect(()=>{if(session)load()},[session]);

  async function load(){
    if(!supabase||!session)return;
    setBusy(true);
    const {data:profile,error:profileError}=await supabase.from('admin_profiles').select('role').eq('id',session.user.id).maybeSingle();
    if(profileError){setMsg('Could not read admin profile: '+profileError.message);setBusy(false);return}
    if(!profile||!['admin','editor'].includes(profile.role)){setMsg('This account ('+session.user.id+') is not assigned a staff role. Add this user ID to admin_profiles in Supabase SQL.');setBusy(false);return}
    setRole(profile.role);

    const {data:rows,error:articlesError}=await supabase.from('articles').select('*').order('created_at',{ascending:false});
    if(articlesError){setMsg('Could not load articles: '+articlesError.message);setBusy(false);return}
    setArticles(rows||[]);

    const {count:viewCount}=await supabase.from('analytics_events').select('*',{count:'exact',head:true}).eq('event_type','page_view');
    const {count:commentCount}=await supabase.from('comments').select('*',{count:'exact',head:true});

    const since=new Date();
    since.setHours(0,0,0,0);
    since.setDate(since.getDate()-29);
    const {data:ev}=await supabase.from('analytics_events').select('created_at,path').eq('event_type','page_view').gte('created_at',since.toISOString()).order('created_at',{ascending:true}).limit(20000);
    setVisits((ev||[]) as Visit[]);

    const {data:subs}=await supabase.from('newsletter_subscribers').select('email,created_at').order('created_at',{ascending:false});
    setSubscribers((subs||[]) as Subscriber[]);

    setStats({views:viewCount||0,articles:(rows||[]).length,comments:commentCount||0,subscribers:(subs||[]).length});
    setBusy(false);
  }

  async function login(e:React.FormEvent){
    e.preventDefault();
    if(!supabase){setMsg('Add your Supabase URL and anon key to .env.local first.');return}
    setBusy(true);
    const {error}=await supabase.auth.signInWithPassword({email,password});
    setMsg(error?.message||'');
    setBusy(false);
  }

  async function save(e:React.FormEvent){
    e.preventDefault();
    if(!supabase||!session)return;
    if(!form.title?.trim()||!form.excerpt?.trim()||!form.content?.trim()){setMsg('Headline, short summary and article text are required.');return}
    setBusy(true);
    const now=new Date().toISOString();
    const payload={
      title:form.title.trim(),
      excerpt:form.excerpt.trim(),
      content:form.content.trim(),
      category:form.category,
      language:form.language,
      image_url:form.image_url||null,
      status:form.status||'draft',
      tags:Array.isArray(form.tags)?form.tags:[],
      updated_at:now,
      published_at:form.status==='published'?(form.published_at||now):null
    };
    const result=editing
      ?await supabase.from('articles').update(payload).eq('id',editing)
      :await supabase.from('articles').insert({...payload,author_id:session.user.id});
    if(result.error){setMsg('Could not save article: '+result.error.message);setBusy(false);return}
    setMsg(editing?'Article updated.':'Article created.');
    setForm(blank);
    setEditing(null);
    await load();
  }

  async function remove(article:Row){
    if(!confirm('Delete "'+article.title+'" permanently?'))return;
    if(!supabase)return;
    setBusy(true);
    const {error}=await supabase.from('articles').delete().eq('id',article.id);
    if(error){setMsg('Could not delete article: '+error.message);setBusy(false);return}
    setMsg('Article deleted.');
    if(editing===article.id){setEditing(null);setForm(blank)}
    await load();
  }

  async function upload(e:any){
    const file=e.target.files?.[0];
    if(!file||!supabase)return;
    setUploading(true);
    const path=`${Date.now()}-${file.name.replace(/[^a-zA-Z0-9._-]/g,'-')}`;
    const {error}=await supabase.storage.from('article-images').upload(path,file,{upsert:false});
    if(error)setMsg('Image upload failed: '+error.message);
    else{
      const {data}=supabase.storage.from('article-images').getPublicUrl(path);
      setForm({...form,image_url:data.publicUrl});
      setMsg('Image uploaded.');
    }
    setUploading(false);
    e.target.value='';
  }

  function startEdit(article:Row){
    setForm({...article});
    setEditing(article.id);
    setMsg('Editing "'+article.title+'". Make your changes and click Save changes.');
    window.scrollTo({top:0,behavior:'smooth'});
  }

  async function copyEmails(){
    if(!subscribers.length){setMsg('No subscribers to copy yet.');return}
    try{await navigator.clipboard.writeText(subscribers.map(s=>s.email).join('\n'));setMsg('Copied '+subscribers.length+' subscriber emails to the clipboard.')}
    catch{setMsg('Could not copy emails. Select them manually from the list below.')}
  }

  if(!supabase)return <><Header/><div className="adminwrap"><h1 className="headline">Admin setup</h1><div className="notice">Supabase is not connected yet. Copy <code>.env.example</code> to <code>.env.local</code>, add your project URL and anon key, then restart the development server.</div><Link className="button" href="/">Back to website</Link></div><Footer/></>;

  if(!session)return <><Header/><div className="adminwrap" style={{maxWidth:500}}><div className="eyebrow">TRUE BALLERS NEWSROOM</div><h1 className="headline">Admin login</h1><p>Sign in with the account you created in Supabase Authentication.</p><form className="panel" onSubmit={login}><div className="field"><label>Email</label><input type="email" value={email} onChange={e=>setEmail(e.target.value)} required/></div><div className="field"><label>Password</label><input type="password" value={password} onChange={e=>setPassword(e.target.value)} required/></div><button className="button" disabled={busy}>{busy?'Signing in…':'Sign in'}</button>{msg&&<div className="notice">{msg}</div>}</form></div><Footer/></>;

  const recent=[...visits].reverse().slice(0,50);

  return <><Header/><main className="adminwrap">
    <div className="adminhead"><div><div className="eyebrow">CONTENT MANAGEMENT</div><h1 className="headline">Newsroom dashboard</h1><p className="meta">Signed in as {session.user.email} · {role||'staff'}</p></div><div className="pillrow"><button className="button dark" onClick={()=>supabase.auth.signOut()}>Sign out</button><Link className="button" href="/">View website</Link></div></div>

    {msg&&<div className="notice">{msg}</div>}
    {busy&&<div className="notice">Working…</div>}

    <div className="statgrid">
      <div className="stat"><span className="meta">Total page views</span><strong>{stats.views}</strong><small>Recorded since analytics was connected</small></div>
      <div className="stat"><span className="meta">Articles</span><strong>{stats.articles}</strong><small>Drafts and published articles</small></div>
      <div className="stat"><span className="meta">Subscribers</span><strong>{stats.subscribers}</strong><small>Emails collected by the newsletter form</small></div>
    </div>

    <div className="pillrow" style={{margin:'22px 0'}}>{[['articles','Articles'],['analytics','Analytics']].map(([k,v])=><button key={k} className={'pill '+(tab===k?'active':'')} onClick={()=>setTab(k)}>{v}</button>)}</div>

    {tab==='analytics'?<>
      <section className="panel">
        <h2>Visitors over time</h2>
        <p>Daily page views recorded by the website over the last 30 days.</p>
        <TrafficChart visits={visits}/>
        <p className="meta" style={{marginTop:12}}>Analytics counts page views, so one person browsing several pages may be counted more than once.</p>
      </section>

      <section className="panel">
        <div style={{display:'flex',justifyContent:'space-between',alignItems:'center',gap:10,flexWrap:'wrap'}}>
          <div><h2>Newsletter subscribers</h2><p>{subscribers.length} email{subscribers.length===1?'':'s'} subscribed.</p></div>
          <button className="button" onClick={copyEmails} disabled={!subscribers.length}>Copy all emails</button>
        </div>
        {subscribers.length?<div className="tablewrap"><table className="admintable"><thead><tr><th>#</th><th>Email</th><th>Subscribed</th></tr></thead><tbody>{subscribers.map((s,i)=><tr key={s.email}><td>{i+1}</td><td><a href={'mailto:'+s.email}>{s.email}</a></td><td>{s.created_at?new Date(s.created_at).toLocaleString():'—'}</td></tr>)}</tbody></table></div>:<p>No subscribers yet. Emails submitted through the website newsletter form will appear here.</p>}
      </section>

      <section className="panel">
        <h2>Recent page views</h2>
        <p>Latest recorded page views (up to 50).</p>
        <div className="tablewrap"><table className="admintable"><thead><tr><th>Date / time</th><th>Page</th></tr></thead><tbody>{recent.map((v,i)=><tr key={i}><td>{new Date(v.created_at).toLocaleString()}</td><td>{v.path}</td></tr>)}</tbody></table></div>
        {!recent.length&&<p>No page views recorded yet.</p>}
      </section>
    </>:<div className="admin-grid">
      <section className="panel">
        <h2>{editing?'Edit article':'Create article'}</h2>
        <form onSubmit={save}>
          <div className="field"><label>Headline</label><input value={form.title||''} onChange={e=>setForm({...form,title:e.target.value})} required/></div>
          <div className="field"><label>Short summary</label><textarea rows={3} value={form.excerpt||''} onChange={e=>setForm({...form,excerpt:e.target.value})} required/></div>
          <div className="field"><label>Article content</label><textarea rows={8} value={form.content||''} onChange={e=>setForm({...form,content:e.target.value})} required/></div>
          <div className="field"><label>Category</label><select value={form.category} onChange={e=>setForm({...form,category:e.target.value})}>{categories.map(x=><option key={x}>{x}</option>)}</select></div>
          <div className="field"><label>Language</label><select value={form.language} onChange={e=>setForm({...form,language:e.target.value})}><option value="rw">Kinyarwanda</option><option value="en">English</option><option value="fr">French</option></select></div>
          <div className="field"><label>Image URL or uploaded image</label><input value={form.image_url||''} onChange={e=>setForm({...form,image_url:e.target.value})} placeholder="https://..."/><input type="file" accept="image/*" onChange={upload}/>{uploading&&<small>Uploading image…</small>}</div>
          <div className="field"><label>Status</label><select value={form.status||'draft'} onChange={e=>setForm({...form,status:e.target.value})}><option value="draft">Save as draft</option><option value="published">Publish now</option></select></div>
          <div className="pillrow">
            <button className="button" disabled={busy}>{editing?'Save changes':'Save article'}</button>
            <button type="button" className="button light" onClick={()=>{setForm(blank);setEditing(null);setMsg('')}}>Clear</button>
            {editing&&<Link className="button light" href={'/article/'+editing} target="_blank" rel="noreferrer">View article</Link>}
          </div>
        </form>
      </section>
      <section>
        <div className="panel">
          <h2>Articles ({articles.length})</h2>
          <div className="tablewrap">
            <table className="admintable">
              <thead><tr><th>Headline</th><th>Status</th><th>Actions</th></tr></thead>
              <tbody>{articles.map(a=><tr key={a.id}>
                <td><strong>{a.title}</strong><br/><small>{a.category} · {a.language} · {a.status}</small></td>
                <td>{(a as any).status}</td>
                <td><div className="pillrow">
                  <Link className="pill" href={'/article/'+a.id} target="_blank" rel="noreferrer">View</Link>
                  <button className="pill" onClick={()=>startEdit(a)}>Edit</button>
                  <button className="pill" onClick={()=>remove(a)}>Delete</button>
                </div></td>
              </tr>)}</tbody>
            </table>
          </div>
          {!articles.length&&<p>No database articles yet. Create your first article with the form.</p>}
        </div>
        <div className="notice">Drafts stay private. Use View while signed in to preview a draft, then publish only after checking names, scores, photos and sources.</div>
      </section>
    </div>}
  </main><Footer/></>;
}
